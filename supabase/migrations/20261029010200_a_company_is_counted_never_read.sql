-- Ekwo OS — a company is counted, never read.
--
-- Whoever runs an installation for somebody else — a host keeping an
-- instance alive, an operator linked to it by a key — needs to know whether
-- the books are in use: how many contacts, how many invoices drafted and
-- posted, how many entries, when the last thing was written. Until now the
-- only way to find out was to count table by table with a key that reads far
-- more than counts, or with the `service_role` key, which reads everything.
--
-- `usage_figures()` answers that question and nothing else. For every company
-- the caller is on, it returns one row per figure: a name, a number of rows,
-- and the moment the most recent of them was created. A figure is a count of
-- the objects people make; no name, no amount, no label and no identifier
-- other than the company's own leaves the function. The exact list, and what
-- it leaves out, is `docs/usage-figures.md`.
--
-- What it leaves out on purpose: what the country pack lays down when a
-- company is created — accounts, taxes, tax postings, journals, declaration
-- boxes. Those are the same for every company of a country and say nothing
-- about whether anybody keeps books there.
--
-- Modules are counted without the socle naming one. For each module enabled
-- on the company, the function returns `modules.<code>`, then one figure per
-- table of the module's schema that carries `company_id`, as `<code>.<table>`.
-- A table of a module that carries no `company_id` is reference data of the
-- installation (rule 3 of `docs/modules.md`) and is not counted. A module
-- installed tomorrow is counted by the same loop.
--
-- Who may ask: a caller this installation knows, for the companies it is on —
-- `is_company_member()`, which answers for a signed-in member and for the
-- holder of a key of that company. A key needs no capability for it: what it
-- learns is less than what any capability already lets it read. A stranger,
-- or a member asking about another company, gets no rows.
--
-- Definer, because it counts tables whose policies would each ask a
-- different capability; read-only, so it runs in the read-only transaction
-- PostgREST opens for an RPC that is not volatile.
--
-- The function lives in the socle's schema, `ekwo` (decision 0090), and names
-- every table of it qualified; a module's tables are found through
-- `ekwo.modules.schema_name`, wherever that schema is.

create or replace function ekwo.usage_figures()
returns table (company_id uuid, figure text, count bigint, last_created_at timestamptz)
language plpgsql
stable
security definer
set search_path = ekwo, pg_temp
as $$
#variable_conflict use_column
declare
  v_company uuid;
  v_module  record;
  v_table   record;
  v_count   bigint;
  v_last    timestamptz;
begin
  for v_company in
    select c.id from ekwo.companies c where ekwo.is_company_member(c.id) order by c.id
  loop
    return query
      select v_company, f.figure, f.n, f.last
        from (
          select 'members'::text as figure, count(*) as n, max(m.created_at) as last
            from ekwo.company_members m where m.company_id = v_company
          union all
          select 'invitations', count(*), max(i.created_at)
            from ekwo.company_invitations i where i.company_id = v_company
          union all
          select 'contacts', count(*), max(c.created_at)
            from ekwo.contacts c where c.company_id = v_company
          union all
          select 'products', count(*), max(p.created_at)
            from ekwo.products p where p.company_id = v_company
          union all
          select 'fiscal_years', count(*), max(y.created_at)
            from ekwo.fiscal_years y where y.company_id = v_company
          union all
          select 'bank_accounts', count(*), max(b.created_at)
            from ekwo.bank_accounts b where b.company_id = v_company
          union all
          select 'bank_statements', count(*), max(s.created_at)
            from ekwo.bank_statements s where s.company_id = v_company
          union all
          select 'payments', count(*), max(p.created_at)
            from ekwo.payments p where p.company_id = v_company
          union all
          select 'book_imports', count(*), max(b.created_at)
            from ekwo.book_imports b where b.company_id = v_company
          union all
          select 'tax_filings', count(*), max(t.created_at)
            from ekwo.tax_filings t where t.company_id = v_company
          union all
          select 'vat_schemes', count(*), max(v.created_at)
            from ekwo.company_vat_schemes v where v.company_id = v_company
          union all
          select 'declaration_instalments', count(*), max(d.created_at)
            from ekwo.declaration_instalments d where d.company_id = v_company
          union all
          select 'attachments', count(*), max(a.created_at)
            from ekwo.attachments a where a.company_id = v_company
        ) f
       order by f.figure;

    -- Documents by type and state, entries by state: a group with no row is
    -- not returned, since a type nobody used is not a figure.
    return query
      select v_company, 'documents.' || d.doc_type || '.' || d.state, count(*), max(d.created_at)
        from ekwo.documents d
       where d.company_id = v_company
       group by d.doc_type, d.state
       order by 2;

    return query
      select v_company, 'entries.' || e.state, count(*), max(e.created_at)
        from ekwo.entries e
       where e.company_id = v_company
       group by e.state
       order by 2;

    for v_module in
      select m.code, m.schema_name, cm.enabled_at
        from ekwo.company_modules cm
        join ekwo.modules m on m.code = cm.module_code
       where cm.company_id = v_company
       order by m.code
    loop
      company_id := v_company;
      figure := 'modules.' || v_module.code;
      count := 1;
      last_created_at := v_module.enabled_at;
      return next;

      for v_table in
        select c.relname,
               exists (select 1 from pg_attribute a
                        where a.attrelid = c.oid and a.attname = 'created_at'
                          and a.attnum > 0 and not a.attisdropped) as dated
          from pg_class c
          join pg_namespace n on n.oid = c.relnamespace
         where n.nspname = v_module.schema_name
           and c.relkind in ('r', 'p')
           and exists (select 1 from pg_attribute a
                        where a.attrelid = c.oid and a.attname = 'company_id'
                          and a.attnum > 0 and not a.attisdropped)
         order by c.relname
      loop
        execute format(
          'select count(*), %s from %I.%I where company_id = $1',
          case when v_table.dated then 'max(created_at)' else 'null::timestamptz' end,
          v_module.schema_name, v_table.relname)
          into v_count, v_last
          using v_company;
        company_id := v_company;
        figure := v_module.code || '.' || v_table.relname;
        count := v_count;
        last_created_at := v_last;
        return next;
      end loop;
    end loop;
  end loop;
end;
$$;

comment on function ekwo.usage_figures() is
  'How much each company the caller is on is used: one row per figure — a name, a number of rows, and when the most recent was created. Counts of what people make (members, contacts, documents by type and state, entries by state, bank statements, payments, VAT schemes and instalments, modules and their tables, the list of docs/usage-figures.md); never a name, an amount or a label, and nothing the country pack lays down. A signed-in member or the holder of a key of the company; no rows for anybody else.';

revoke execute on function ekwo.usage_figures() from public, anon;
grant execute on function ekwo.usage_figures() to authenticated, service_role;

-- `create or replace` keeps the privileges the function already had, and the
-- revoke is what every file of this directory ends with.
revoke execute on all functions in schema ekwo from public;

notify pgrst, 'reload schema';
