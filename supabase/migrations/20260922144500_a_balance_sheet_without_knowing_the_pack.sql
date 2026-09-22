-- Ekwo OS — asking for a balance sheet without knowing which pack answers.
--
-- `financial_statement()` takes `p_statement_code`, and a code belongs to a
-- country pack: `BE-BNB-ABBR-BS`, `FR-2050`, the generic `IFRS-SME-BS`. A
-- client that knows which company it is looking at does not know that string,
-- and it must not learn it — writing `FR-2050` into an application is writing
-- a country into code, one screen at a time, which is the thing
-- `docs/decisions/0025` exists to stop.
--
-- `available_statements(company, at)` has been the way out since the day the
-- statements landed: it gives every scheme that company may ask for, with its
-- kind and whether its chart declares it. What was missing is the step after
-- it — going from *a balance sheet* to the one statement that answers, and
-- doing it the same way twice. Every caller that wanted one wrote its own
-- choice: take the first row, prefer `is_default`, prefer the country over the
-- generic. Three readers, three orders, and the day a pack carries two balance
-- sheets they disagree about which is the company's.
--
-- Two functions, and no new rule about accounting:
--
--   `default_statement_code(company, kind, at)` — the one scheme of that kind
--       this company reports on. The order is the pack's own preferences,
--       stated once: a statement the company's chart declares
--       (`chart_templates.statements`, which is what `is_default` marks) comes
--       first; then one of the company's country, because a national scheme is
--       what an administration reads; then the generic framework, which fits
--       any chart and is the fallback and never the first answer. `code`
--       settles a tie, so the answer does not depend on the order rows were
--       loaded in.
--
--   `financial_statement_of_kind(company, kind, from, to)` — the same table
--       `financial_statement()` returns, resolved that way, with the code it
--       chose in the first column. The code comes back because a reader has to
--       be able to say which scheme it is printing, and because the next call
--       — `unmapped_accounts()`, an XBRL export — takes the code.
--
-- The kind is the one the schema already has: `balance_sheet`,
-- `income_statement`, `allocation`, `cash_flow` — the vocabulary of
-- `statement_templates.kind`, not a new one. A company with no statement of
-- the kind asked for is told so, and told what it does have; a company that
-- installed no pack at all has the generic framework and so has both of the
-- two that are produced.
--
-- The date the validity is read at is `p_to`: a statement is the one that was
-- in force at the end of the period being reported, not the one in force
-- today. A scheme replaced last month still prints last year.

create or replace function default_statement_code(
  p_company_id uuid,
  p_kind       text,
  p_at         date default null
)
returns text
language sql
stable
as $$
  select s.code
    from available_statements(p_company_id, p_at) s
   where s.kind = p_kind
   order by s.is_default desc, (s.country is null), s.code
   limit 1;
$$;

comment on function default_statement_code(uuid, text, date) is
  'The statement of a kind this company reports on: one its chart declares, else one of its country, else the generic framework. Null when it has none of that kind. The one place that choice is made, so two readers cannot disagree about which balance sheet is the company''s.';

create or replace function financial_statement_of_kind(
  p_company_id uuid,
  p_kind       text,
  p_from       date,
  p_to         date
)
returns table (
  statement_code text,
  line_code      text,
  parent_code    text,
  name           text,
  sequence       integer,
  is_total       boolean,
  amount         numeric,
  xbrl_element   text
)
language plpgsql
stable
as $$
declare
  v_code  text;
  v_kinds text;
begin
  if not exists (select 1 from companies c where c.id = p_company_id) then
    raise exception 'unknown_company: %', p_company_id;
  end if;

  v_code := default_statement_code(p_company_id, p_kind, p_to);
  if v_code is null then
    select string_agg(distinct s.kind, ', ' order by s.kind) into v_kinds
      from available_statements(p_company_id, p_to) s;
    raise exception 'unknown_statement: this company reports no % — it reports %. available_statements() names each one by code.',
      p_kind, coalesce(v_kinds, 'nothing');
  end if;

  return query
    select v_code, f.line_code, f.parent_code, f.name, f.sequence,
           f.is_total, f.amount, f.xbrl_element
      from financial_statement(p_company_id, v_code, p_from, p_to) f;
end;
$$;

comment on function financial_statement_of_kind(uuid, text, date, date) is
  'One financial statement of a company by kind — balance_sheet, income_statement, allocation, cash_flow — for a caller that does not know which scheme its country pack carries. Resolves through default_statement_code() at the end date of the period, then answers as financial_statement() does, with the code it chose in the first column.';

revoke execute on all functions in schema public from public;

revoke execute on function default_statement_code(uuid, text, date) from public, anon;
grant execute on function default_statement_code(uuid, text, date) to authenticated, service_role;
revoke execute on function financial_statement_of_kind(uuid, text, date, date) from public, anon;
grant execute on function financial_statement_of_kind(uuid, text, date, date) to authenticated, service_role;
