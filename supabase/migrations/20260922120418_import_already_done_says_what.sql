-- Ekwo OS — a second import of the same files says what the first one was.
--
-- `import_books()` refuses files it has already imported, by their checksum,
-- and the refusal said when and then "(% entries, % to %)". For a trial
-- balance — the first thing most people import, and an import with no entry
-- at all — that read "0 entries, — to —": true, and no help to somebody
-- trying to remember what they did. The row in `book_imports` knows more: the
-- file names, the source, the time, and the number of the opening entry.
--
-- So the refusal names them: which files, read as which source, imported when
-- (to the minute, in UTC, since a person may import twice in one day), and
-- what that import wrote — its entries with their first and last number, its
-- opening entry by number, or both. The function is otherwise the one of
-- `20260922081645_books_taken_over_from_an_export`, republished whole because
-- a function body cannot be patched.

create or replace function import_books(
  p_company_id            uuid,
  p_books                 jsonb,
  p_dry_run               boolean default false,
  p_open_years            boolean default false,
  p_allow_result_accounts boolean default false
)
returns jsonb
language plpgsql
volatile
security invoker
as $$
declare
  v_checksum   text := p_books ->> 'checksum';
  v_source     text := p_books ->> 'source';
  v_previous   book_imports;
  v_result     jsonb;
  v_contacts   jsonb := '{}'::jsonb;
  v_contact    jsonb;
  v_contact_id uuid;
  v_created    integer := 0;
  v_found      integer := 0;
  v_entry      jsonb;
  v_draft      entries;
  v_journal    uuid;
  v_date       date;
  v_missing    text;
  v_years      jsonb := '[]'::jsonb;
  v_year       uuid;
  v_entries    integer := 0;
  v_lines      integer := 0;
  v_first      text;
  v_last       text;
  v_opening    jsonb := p_books -> 'opening';
  v_opening_id uuid;
  v_opening_no text;
  v_debit      numeric := 0;
  v_credit     numeric := 0;
  v_journals   jsonb;
begin
  if not exists (select 1 from companies c where c.id = p_company_id) then
    raise exception 'unknown_company: %', p_company_id using errcode = 'no_data_found';
  end if;
  -- Row level security is what refuses; this is what says why.
  if not coalesce(is_installer(), false) then
    if not coalesce(has_capability(p_company_id, 'entries.write'), false)
       or not coalesce(has_capability(p_company_id, 'entries.post'), false) then
      raise exception 'not_allowed: importing books into this company needs entries.write and entries.post'
        using errcode = '42501';
    end if;
  end if;
  if v_source is null or v_checksum is null then
    raise exception 'invalid_books: the books name no source or no checksum — expected them as the importer builds them';
  end if;
  if jsonb_typeof(coalesce(p_books -> 'entries', '[]'::jsonb)) <> 'array' then
    raise exception 'invalid_books: entries must be a list';
  end if;
  if jsonb_array_length(coalesce(p_books -> 'entries', '[]'::jsonb)) = 0
     and (v_opening is null or jsonb_typeof(v_opening) = 'null') then
    raise exception 'import_empty: the files hold no entry and no balance; there is nothing to import';
  end if;

  select * into v_previous from book_imports b
   where b.company_id = p_company_id and b.checksum = v_checksum;
  if found then
    raise exception 'import_already_done: % (%) was imported on % UTC: %. Importing it again would count every amount twice',
      coalesce(nullif(array_to_string(v_previous.file_names, ', '), ''), 'the same file'),
      v_previous.source,
      to_char(v_previous.created_at at time zone 'UTC', 'YYYY-MM-DD HH24:MI'),
      concat_ws(' and ',
        case when v_previous.entry_count > 0 then
          v_previous.entry_count || case when v_previous.entry_count = 1 then ' entry' else ' entries' end
          || coalesce(', numbered ' || v_previous.first_number
                      || case when v_previous.last_number is distinct from v_previous.first_number
                              then ' to ' || v_previous.last_number else '' end, '')
        end,
        case when v_previous.opening_number is not null then
          'the opening entry ' || v_previous.opening_number
        end,
        v_previous.line_count || case when v_previous.line_count = 1 then ' line' else ' lines' end)
      using errcode = '23505';
  end if;

  begin
    -- 1. The years. Each date that falls in none is refused by name, or opened
    --    when the caller asked for it.
    for v_date in
      select distinct d::date from (
        select e ->> 'date' as d from jsonb_array_elements(coalesce(p_books -> 'entries', '[]'::jsonb)) e
        union
        select v_opening ->> 'date' where v_opening is not null and jsonb_typeof(v_opening) <> 'null'
      ) dates
      where d is not null
      order by 1
    loop
      if fiscal_year_at(p_company_id, v_date) is null then
        if not p_open_years then
          raise exception 'import_outside_fiscal_year: % falls in no fiscal year of this company. Open that year, or ask the import to open the years it needs',
            v_date
            using errcode = '55006';
        end if;
        v_year := import_fiscal_year_for(p_company_id, v_date);
        select v_years || jsonb_build_object('name', f.name, 'start_date', f.start_date::text, 'end_date', f.end_date::text)
          into v_years from fiscal_years f where f.id = v_year;
      end if;
    end loop;

    -- 2. The parties: by the code the source gave them, then by their name,
    --    or created. A party the file names once is still one party.
    for v_contact in select value from jsonb_array_elements(coalesce(p_books -> 'contacts', '[]'::jsonb)) loop
      v_contact_id := null;
      if nullif(v_contact ->> 'auxiliary_code', '') is not null then
        select c.id into v_contact_id from contacts c
         where c.company_id = p_company_id and c.auxiliary_code = v_contact ->> 'auxiliary_code'
         order by c.created_at limit 1;
      end if;
      if v_contact_id is null then
        select c.id into v_contact_id from contacts c
         where c.company_id = p_company_id and lower(c.name) = lower(v_contact ->> 'name')
         order by c.created_at limit 1;
      end if;
      if v_contact_id is null then
        insert into contacts (company_id, name, contact_type, auxiliary_code,
                              vat_number, registration_number, email, country)
        values (p_company_id, v_contact ->> 'name',
                coalesce(v_contact ->> 'contact_type', 'other')::contact_type,
                nullif(v_contact ->> 'auxiliary_code', ''),
                nullif(v_contact ->> 'vat_number', ''),
                nullif(v_contact ->> 'registration_number', ''),
                nullif(v_contact ->> 'email', ''),
                nullif(upper(v_contact ->> 'country'), ''))
        returning id into v_contact_id;
        v_created := v_created + 1;
      else
        v_found := v_found + 1;
      end if;
      v_contacts := v_contacts || jsonb_build_object(v_contact ->> 'key', v_contact_id);
    end loop;

    -- 3. The accounts every line names, all of them, before anything is
    --    written: one refusal that lists them is worth more than the first.
    select string_agg(distinct code, ', ' order by code) into v_missing
      from (
        select l ->> 'account_code' as code
          from jsonb_array_elements(coalesce(p_books -> 'entries', '[]'::jsonb)) e,
               jsonb_array_elements(e -> 'lines') l
        union
        select l ->> 'account_code'
          from jsonb_array_elements(coalesce(v_opening -> 'lines', '[]'::jsonb)) l
      ) wanted
     where not exists (select 1 from accounts a where a.company_id = p_company_id and a.code = wanted.code);
    if v_missing is not null then
      raise exception 'unknown_account: % % not in the chart of this company. Map each to an account of the chart',
        v_missing, case when v_missing like '%,%' then 'are' else 'is' end
        using errcode = 'no_data_found';
    end if;

    -- 4. The entries, each a draft and then posted by post_entry().
    for v_entry in select value from jsonb_array_elements(coalesce(p_books -> 'entries', '[]'::jsonb)) loop
      select j.id into v_journal from journals j
       where j.company_id = p_company_id and j.code = v_entry ->> 'journal_code';
      if v_journal is null then
        raise exception 'unknown_journal: % is not a journal of this company', v_entry ->> 'journal_code'
          using errcode = 'no_data_found';
      end if;

      insert into entries (company_id, journal_id, entry_date, number, reference, description, state, currency_code)
      select p_company_id, v_journal, (v_entry ->> 'date')::date,
             nullif(v_entry ->> 'number', ''),
             nullif(v_entry ->> 'reference', ''),
             nullif(v_entry ->> 'description', ''),
             'draft', c.currency_code
        from companies c where c.id = p_company_id
      returning * into v_draft;

      insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit,
                               contact_id, currency_code, amount_currency, date_maturity)
      select v_draft.id, p_company_id, a.id, (l.ordinality * 10)::integer,
             nullif(l.value ->> 'label', ''),
             coalesce((l.value ->> 'debit')::numeric, 0),
             coalesce((l.value ->> 'credit')::numeric, 0),
             case when l.value ->> 'contact_key' is null then null
                  else (v_contacts ->> (l.value ->> 'contact_key'))::uuid end,
             nullif(l.value ->> 'currency_code', ''),
             nullif(l.value ->> 'amount_currency', '')::numeric,
             nullif(l.value ->> 'date_maturity', '')::date
        from jsonb_array_elements(v_entry -> 'lines') with ordinality l
        join accounts a on a.company_id = p_company_id and a.code = l.value ->> 'account_code';

      v_draft := post_entry(v_draft.id);
      v_entries := v_entries + 1;
      v_lines := v_lines + jsonb_array_length(v_entry -> 'lines');
      v_debit := v_debit + v_draft.total_debit;
      v_credit := v_credit + v_draft.total_credit;
      v_first := coalesce(v_first, v_draft.number);
      v_last := v_draft.number;
    end loop;

    -- 5. The balances, as the opening entry of the year they open.
    if v_opening is not null and jsonb_typeof(v_opening) <> 'null' then
      v_year := fiscal_year_at(p_company_id, (v_opening ->> 'date')::date);
      if (select f.start_date from fiscal_years f where f.id = v_year) <> (v_opening ->> 'date')::date then
        raise exception 'opening_not_first_day: an opening balance is dated on the first day of a fiscal year, and % is not; the year it falls in starts on %',
          v_opening ->> 'date', (select f.start_date from fiscal_years f where f.id = v_year);
      end if;
      v_opening_id := opening_balance(
        p_company_id, v_year,
        (select jsonb_agg(jsonb_build_object(
                  'account_code', l ->> 'account_code',
                  'debit', l ->> 'debit',
                  'credit', l ->> 'credit',
                  'label', coalesce(nullif(l ->> 'label', ''), 'Opening balance'),
                  'contact_id', case when l ->> 'contact_key' is null then null
                                     else v_contacts ->> (l ->> 'contact_key') end))
           from jsonb_array_elements(v_opening -> 'lines') l),
        p_allow_result_accounts);
      select e.number into v_opening_no from entries e where e.id = v_opening_id;
      v_lines := v_lines + jsonb_array_length(v_opening -> 'lines');
    end if;

    select coalesce(jsonb_agg(jsonb_build_object('journal_code', j.code, 'entries', n) order by j.code), '[]'::jsonb)
      into v_journals
      from (select e ->> 'journal_code' as code, count(*) as n
              from jsonb_array_elements(coalesce(p_books -> 'entries', '[]'::jsonb)) e
             group by 1) per
      join journals j on j.company_id = p_company_id and j.code = per.code;

    insert into book_imports (company_id, source, checksum, file_names, entry_count, line_count,
                              first_number, last_number, opening_number)
    values (p_company_id, v_source, v_checksum,
            coalesce((select array_agg(value) from jsonb_array_elements_text(coalesce(p_books -> 'file_names', '[]'::jsonb))), '{}'),
            v_entries, v_lines, v_first, v_last, v_opening_no);

    v_result := jsonb_build_object(
      'dry_run', p_dry_run,
      'source', v_source,
      'entries', v_entries,
      'lines', v_lines,
      'total_debit', v_debit::text,
      'total_credit', v_credit::text,
      'first_number', v_first,
      'last_number', v_last,
      'opening_number', v_opening_no,
      'journals', v_journals,
      'contacts_created', v_created,
      'contacts_found', v_found,
      'fiscal_years_opened', v_years
    );

    if p_dry_run then
      -- The way out of the block that undoes everything done inside it. A
      -- variable is not part of the transaction, so the answer survives.
      raise exception using errcode = 'EKW01', message = 'rehearsal';
    end if;
  exception
    when sqlstate 'EKW01' then
      null;
  end;

  return v_result;
end;
$$;

comment on function import_books(uuid, jsonb, boolean, boolean, boolean) is
  'Takes over books read from another system, whole or not at all: the fiscal years they need (p_open_years), their parties, every entry posted through post_entry() and a trial balance through opening_balance(). Account codes arrive already translated into the company''s chart. p_dry_run does all of it and rolls it back, so the answer and the refusals are the real ones. The same files twice are refused (import_already_done).';

revoke execute on function import_books(uuid, jsonb, boolean, boolean, boolean) from public, anon;
grant execute on function import_books(uuid, jsonb, boolean, boolean, boolean) to authenticated, service_role;
