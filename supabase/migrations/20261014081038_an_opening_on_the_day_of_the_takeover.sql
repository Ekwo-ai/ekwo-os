-- Ekwo OS — an opening on the day the books were taken over, whose open
-- items are documents.
--
-- Reported by Pieterjan Muller on 0.12.0 (issue #92).
--
-- `opening_balance()` was dated on the first day of a fiscal year, and its
-- lines kept an account, a side, an amount and at most a contact. A company
-- that changes software in July arrives with a trial balance at 30 June and a
-- list of invoices still open — each with its number, the structured payment
-- reference the customer will quote, its due date. The first was refused
-- (`opening_not_first_day`, in `import_books()`), and the second had nowhere
-- to go: the receivable became one line per customer, and when the customer
-- paid, `suggest_matches()` had no number and no reference to find.
--
-- **The opening takes a day.** `p_opening_date`, any day of the fiscal year,
-- its first day when left out. The opening entry is dated there. Before it the
-- year holds nothing of these books: what the previous system booked from the
-- first day of the year to the takeover arrives in the opening entry itself —
-- the income and expense accounts at their figure of the day, under
-- `p_allow_result_accounts`, as before. So a trial balance or a statement of
-- the whole year reads what the previous system held plus what was booked
-- since; one that ends the day before the takeover reads nothing; one that
-- starts on or after it reads the year-to-date figures as a movement of the
-- period the takeover falls in. A tax return reads none of it: the opening
-- carries no tax and no box, because the returns of those months were filed
-- by the previous system.
--
-- **The open items are documents.** `p_items`, a list of
-- `{doc_type, number, contact_id, amount, document_date, due_date,
-- payment_reference, supplier_reference, label}`: a sale or purchase invoice
-- or credit note still open at the takeover. Each becomes a document written
-- as a draft and posted by `post_document()` — the one way a document is
-- posted — on the opening journal, booked on the opening day while its
-- `document_date` stays the day it was issued. Its one line carries no tax and
-- names the company's suspense account, the account the pack names under
-- `defaults.roles.suspense`; so its entry puts the amount on the receivable or
-- payable of its contact, with the due date as the maturity, against that
-- account. Nothing is re-booked to revenue or expense: the sale was booked by
-- the previous system, and its figure is in the opening.
--
-- The trial balance still says what the receivable account holds, and the
-- items say who owes it. **An account the items fall on is carried by its
-- items**: the lines of the balance on that account are written on the
-- suspense account instead, and the items, each booked against the suspense
-- account, put the amount back on the receivable or payable, by contact. The
-- suspense account comes out at nothing; the receivable comes out at the
-- figure of the balance. Which is why an account whose items do not add up to
-- its line of the balance is refused, `opening_items_unbalanced`: the open
-- items of an account are its whole balance, and an aged balance that does
-- not agree with the trial balance is the first thing to settle at a takeover,
-- not something to book.
--
-- A chart may keep its suspense account reconcilable — ten packs of this
-- repository do. There, the lines the opening and its items write on it are
-- matched against each other by `reconcile()` before the function returns, so
-- that none of them is left among the open items of the company, where a
-- statement line of the same amount would be offered it.
--
-- The account an item falls on is the one `post_document()` will book it on —
-- `resolve_counterpart_account()` of its contact — so the check and the entry
-- cannot disagree. No account, currency or country is named here.
--
-- Refused by name, before anything is written: an item of another type
-- (`opening_item_type`), with no number (`opening_item_without_number`), whose
-- number is already a document of its type in the company or twice in the
-- list (`opening_item_duplicate`), with no contact of the company
-- (`opening_item_unknown_contact`), no positive amount
-- (`opening_item_amount`), no date of issue (`opening_item_without_date`), an
-- issue after the opening day (`opening_item_after_opening`) or a due date
-- before its issue (`opening_item_due_before_issue`); an opening day outside
-- the year (`opening_date_outside_year`); a company with no suspense account
-- (`no_suspense_account`).
--
-- **One function, not a second one.** The items are checked against the lines
-- of the balance and written in the same transaction as the opening entry; a
-- separate `opening_items()` would have had to find an opening already posted
-- and check against it, in a second call over the API — a second transaction,
-- and an opening that stands for a moment without its items. See
-- `docs/decisions/0067-an-opening-on-the-day-of-the-takeover.md`.
--
-- The two new arguments come last and default to null, so every call written
-- for the four arguments reads the same. Postgres keys a function on its
-- arguments, so the four-argument one is dropped and replaced rather than
-- overloaded: two would make every four-argument call ambiguous.
--
-- `import_books()` is replaced whole for one step: the opening of the files is
-- dated on the day they say — no longer only the first of a year — and takes
-- the open items under `opening.items`, each naming its contact by the key of
-- the files, like a line. Nothing else in it moves.

-- ---------------------------------------------------------------------------
-- 1. opening_balance — `20260914121200`, a day and the open items
-- ---------------------------------------------------------------------------

drop function opening_balance(uuid, uuid, jsonb, boolean);

create function opening_balance(
  p_company_id            uuid,
  p_fiscal_year_id        uuid,
  p_lines                 jsonb,
  p_allow_result_accounts boolean default false,
  p_opening_date          date    default null,
  p_items                 jsonb   default null
)
returns uuid
language plpgsql
as $$
declare
  v_year     fiscal_years%rowtype;
  v_date     date;
  v_journal  uuid;
  v_entry    entries%rowtype;
  v_line     jsonb;
  v_account  uuid;
  v_code     text;
  v_debit    numeric;
  v_credit   numeric;
  v_carries  boolean;
  v_sequence integer := 0;
  v_debits   numeric := 0;
  v_credits  numeric := 0;
  -- An opening balance is the ledger's own, so it is written at the decimals
  -- of the company's currency.
  v_round    money_rounding := rounding_of(p_company_id);
  v_currency char(3);
  v_suspense uuid;
  -- The items, read and checked before anything is written.
  v_items    jsonb := '[]'::jsonb;
  v_item     jsonb;
  v_index    integer := 0;
  v_type     doc_type;
  v_is_sale  boolean;
  v_number   text;
  v_contact  uuid;
  v_amount   numeric;
  v_issued   date;
  v_due      date;
  -- What the items put on each account, debit positive, keyed by account id.
  v_carried  jsonb := '{}'::jsonb;
  v_net      numeric;
  v_document uuid;
  -- The entries whose lines on the suspense account answer each other.
  v_entries  uuid[];
  v_debit_line  uuid;
  v_credit_line uuid;
  v_open        numeric;
  r          record;
begin
  select * into v_year from fiscal_years where id = p_fiscal_year_id;
  if not found then
    raise exception 'unknown_fiscal_year: fiscal year % does not exist', p_fiscal_year_id;
  end if;
  if v_year.company_id <> p_company_id then
    raise exception 'fiscal_year_other_company: fiscal year % does not belong to company %',
      p_fiscal_year_id, p_company_id;
  end if;
  if v_year.is_closed then
    raise exception 'fiscal_year_closed: % is closed', v_year.name
      using errcode = '55006';
  end if;
  if has_opening_entry(p_fiscal_year_id) then
    raise exception 'opening_entry_exists: % already has an opening entry', v_year.name;
  end if;

  v_date := coalesce(p_opening_date, v_year.start_date);
  if v_date < v_year.start_date or v_date > v_year.end_date then
    raise exception 'opening_date_outside_year: % is not a day of %, which runs from % to %',
      v_date, v_year.name, v_year.start_date, v_year.end_date
      using errcode = '22023';
  end if;

  if jsonb_typeof(p_lines) <> 'array' or jsonb_array_length(p_lines) = 0 then
    raise exception 'opening_empty: opening_balance takes a non-empty array of lines';
  end if;
  if p_items is not null and jsonb_typeof(p_items) not in ('array', 'null') then
    raise exception 'opening_items_not_a_list: p_items is a list of open items'
      using errcode = '22023';
  end if;

  v_journal := opening_journal_id(p_company_id);
  if v_journal is null then
    raise exception 'no_opening_journal: the pack of this company names no journal of type opening. Set defaults.journal_roles.opening in the pack, which fills country_defaults.opening_journal_code.'
      using errcode = '55006';
  end if;

  -- ---------------------------------------------------------- the open items
  for v_item in
    select value from jsonb_array_elements(case when jsonb_typeof(p_items) = 'array' then p_items else '[]'::jsonb end)
  loop
    v_index := v_index + 1;
    v_number := nullif(btrim(v_item ->> 'number'), '');

    if v_item ->> 'doc_type' not in ('sale_invoice', 'sale_credit_note',
                                     'purchase_invoice', 'purchase_credit_note')
       or v_item ->> 'doc_type' is null then
      raise exception 'opening_item_type: item % (%) is a %; an open item is a sale_invoice, a sale_credit_note, a purchase_invoice or a purchase_credit_note',
        v_index, coalesce(v_number, 'no number'), coalesce(v_item ->> 'doc_type', 'nothing')
        using errcode = '22023';
    end if;
    v_type    := (v_item ->> 'doc_type')::doc_type;
    v_is_sale := v_type in ('sale_invoice', 'sale_credit_note');

    if v_number is null then
      raise exception 'opening_item_without_number: item % carries no number; the number is what a payment quotes and what the item is found by',
        v_index
        using errcode = '22023';
    end if;
    if exists (select 1 from jsonb_array_elements(v_items) i
                where i ->> 'doc_type' = v_type::text and i ->> 'number' = v_number)
       or exists (select 1 from documents d
                   where d.company_id = p_company_id and d.doc_type = v_type and d.number = v_number) then
      raise exception 'opening_item_duplicate: % % is already a document of this company, or twice in the list; a number is one document',
        v_type, v_number
        using errcode = '23505';
    end if;

    v_contact := null;
    if v_item ->> 'contact_id' ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' then
      select c.id into v_contact from contacts c
       where c.id = (v_item ->> 'contact_id')::uuid and c.company_id = p_company_id;
    end if;
    if v_contact is null then
      raise exception 'opening_item_unknown_contact: % % names no contact of this company; an open item is owed by somebody, or to somebody',
        v_type, v_number
        using errcode = '22023';
    end if;

    v_amount := null;
    if v_item ->> 'amount' ~ '^\s*[0-9]+(\.[0-9]+)?\s*$' then
      v_amount := round_amount((v_item ->> 'amount')::numeric, v_round);
    end if;
    if v_amount is null or v_amount <= 0 then
      raise exception 'opening_item_amount: % % carries %; an open item is a positive amount, and its type says the side',
        v_type, v_number, coalesce('an amount of ' || (v_item ->> 'amount'), 'no amount')
        using errcode = '22023';
    end if;

    v_issued := (v_item ->> 'document_date')::date;
    v_due    := (v_item ->> 'due_date')::date;
    if v_issued is null then
      raise exception 'opening_item_without_date: % % carries no document_date, the day it was issued',
        v_type, v_number
        using errcode = '22023';
    end if;
    if v_issued > v_date then
      raise exception 'opening_item_after_opening: % % was issued on %, after the opening on %; an item still open at the takeover was issued on or before it, and a later one is booked as any document',
        v_type, v_number, v_issued, v_date
        using errcode = '22023';
    end if;
    if v_due < v_issued then
      raise exception 'opening_item_due_before_issue: % % falls due on %, before it was issued on %',
        v_type, v_number, v_due, v_issued
        using errcode = '22023';
    end if;

    -- The account `post_document()` will book it on, asked the same way.
    v_account := resolve_counterpart_account(p_company_id, commercial_entity(v_contact), v_is_sale);
    v_net := case when v_type in ('sale_invoice', 'purchase_credit_note') then v_amount else -v_amount end;
    v_carried := v_carried || jsonb_build_object(
      v_account::text, coalesce((v_carried ->> v_account::text)::numeric, 0) + v_net);

    v_items := v_items || jsonb_build_array(jsonb_build_object(
      'doc_type', v_type, 'number', v_number, 'contact_id', v_contact, 'amount', v_amount,
      'document_date', v_issued, 'due_date', v_due,
      'payment_reference', nullif(btrim(v_item ->> 'payment_reference'), ''),
      'supplier_reference', nullif(btrim(v_item ->> 'supplier_reference'), ''),
      'label', nullif(btrim(v_item ->> 'label'), '')));
  end loop;

  if v_index > 0 then
    select c.suspense_account_id, c.currency_code into v_suspense, v_currency
      from companies c where c.id = p_company_id;
    if v_suspense is null then
      raise exception 'no_suspense_account: the open items are booked against the suspense account of the company, and it has none. Set suspense_account_id on the company; the pack names it under defaults.roles.suspense'
        using errcode = '55006';
    end if;

    -- The open items of an account are its whole balance.
    for r in
      select a.code, (c.value #>> '{}')::numeric as items
        from jsonb_each(v_carried) c
        join accounts a on a.id = c.key::uuid
       order by a.code
    loop
      select coalesce(sum(round_amount(coalesce((l ->> 'debit')::numeric, 0), v_round)
                        - round_amount(coalesce((l ->> 'credit')::numeric, 0), v_round)), 0)
        into v_net
        from jsonb_array_elements(p_lines) l
       where l ->> 'account_code' = r.code;
      if v_net <> r.items then
        raise exception 'opening_items_unbalanced: % opens at % in the balance and its open items come to %; the open items of an account are its whole balance',
          r.code,
          case when v_net >= 0 then 'a debit of ' || v_net else 'a credit of ' || -v_net end,
          case when r.items >= 0 then 'a debit of ' || r.items else 'a credit of ' || -r.items end
          using errcode = '22023';
      end if;
    end loop;
  end if;

  -- --------------------------------------------------------- the opening entry
  perform set_config('ekwo.year_end_entry', 'on', true);
  insert into entries (company_id, journal_id, fiscal_year_id, entry_date,
                       description, state, kind)
  values (p_company_id, v_journal, p_fiscal_year_id, v_date,
          'Opening balance', 'draft', 'opening')
  returning * into v_entry;
  perform set_config('ekwo.year_end_entry', 'off', true);

  for v_line in select * from jsonb_array_elements(p_lines)
  loop
    v_sequence := v_sequence + 10;
    v_code := v_line ->> 'account_code';
    if v_code is null then
      raise exception 'opening_line_without_account: line % names no account_code', v_sequence / 10;
    end if;

    v_account := null;
    select a.id, a.carries_forward into v_account, v_carries
      from accounts a
     where a.company_id = p_company_id and a.code = v_code;
    if v_account is null then
      raise exception 'unknown_account: % is not an account of this company', v_code;
    end if;
    if not v_carries and not p_allow_result_accounts then
      raise exception 'opening_result_account: % is an income or expense account; an opening balance is made of the balance sheet. Pass p_allow_result_accounts when taking over books mid-year.',
        v_code;
    end if;

    v_debit  := round_amount(coalesce((v_line ->> 'debit')::numeric, 0), v_round);
    v_credit := round_amount(coalesce((v_line ->> 'credit')::numeric, 0), v_round);
    if v_debit < 0 or v_credit < 0 then
      raise exception 'opening_negative_amount: % has a negative amount; a side is chosen, never a sign', v_code;
    end if;
    if v_debit <> 0 and v_credit <> 0 then
      raise exception 'opening_two_sides: % carries both a debit and a credit', v_code;
    end if;
    if v_debit = 0 and v_credit = 0 then
      raise exception 'opening_no_amount: % carries neither a debit nor a credit', v_code;
    end if;

    if v_carried ? v_account::text then
      -- Carried by its items: the balance waits on the suspense account, and
      -- each item, booked against it, puts its share back by contact.
      insert into entry_lines (entry_id, company_id, account_id, sequence, name,
                               debit, credit)
      values (v_entry.id, p_company_id, v_suspense, v_sequence,
              'Open items of ' || v_code,
              v_debit, v_credit);
    else
      insert into entry_lines (entry_id, company_id, account_id, sequence, name,
                               debit, credit, contact_id)
      values (v_entry.id, p_company_id, v_account, v_sequence,
              coalesce(v_line ->> 'label', 'Opening balance'),
              v_debit, v_credit, (v_line ->> 'contact_id')::uuid);
    end if;

    v_debits  := v_debits + v_debit;
    v_credits := v_credits + v_credit;
  end loop;

  if v_debits <> v_credits then
    raise exception 'opening_unbalanced: the opening balance has debit % and credit %',
      v_debits, v_credits;
  end if;

  v_entry := post_entry(v_entry.id);
  v_entries := array[v_entry.id];

  -- -------------------------------------------------------- the open items
  for v_item in select value from jsonb_array_elements(v_items)
  loop
    insert into documents (company_id, doc_type, number, supplier_reference, contact_id,
                           journal_id, document_date, accounting_date, due_date,
                           currency_code, payment_reference)
    values (p_company_id, (v_item ->> 'doc_type')::doc_type, v_item ->> 'number',
            v_item ->> 'supplier_reference', (v_item ->> 'contact_id')::uuid,
            v_journal, (v_item ->> 'document_date')::date, v_date,
            (v_item ->> 'due_date')::date, v_currency, v_item ->> 'payment_reference')
    returning id into v_document;

    insert into document_lines (document_id, company_id, sequence, name, quantity,
                                unit_price, account_id)
    values (v_document, p_company_id, 10,
            coalesce(v_item ->> 'label', 'Open at the takeover'), 1,
            (v_item ->> 'amount')::numeric, v_suspense);

    v_entries := v_entries || (post_document(v_document)).id;
  end loop;

  -- A chart may keep its suspense account reconcilable. Its lines here answer
  -- each other and add up to nothing, so they are matched against each other
  -- now: left open, they would sit among the open items of the company, where
  -- a statement line of the same amount would be offered them.
  if v_index > 0 and (select a.reconcilable from accounts a where a.id = v_suspense) then
    loop
      select l.id into v_debit_line from entry_lines l
       where l.entry_id = any(v_entries) and l.account_id = v_suspense
         and l.debit > 0 and abs(l.balance) - l.matched_amount > 0
       order by l.entry_id = v_entry.id desc, l.sequence, l.id limit 1;
      select l.id into v_credit_line from entry_lines l
       where l.entry_id = any(v_entries) and l.account_id = v_suspense
         and l.credit > 0 and abs(l.balance) - l.matched_amount > 0
       order by l.entry_id = v_entry.id desc, l.sequence, l.id limit 1;
      exit when v_debit_line is null or v_credit_line is null;
      select least(abs(d.balance) - d.matched_amount, abs(c.balance) - c.matched_amount)
        into v_open
        from entry_lines d, entry_lines c
       where d.id = v_debit_line and c.id = v_credit_line;
      perform reconcile(v_debit_line, v_credit_line, v_open);
      v_debit_line  := null;
      v_credit_line := null;
    end loop;
  end if;

  return v_entry.id;
end;
$$;

comment on function opening_balance(uuid, uuid, jsonb, boolean, date, jsonb) is
  'Posts a trial balance from a previous system as the opening entry of a fiscal year, on p_opening_date — the day the books were taken over, the first day of the year by default. Balance-sheet accounts only, unless the caller allows the others. p_items are the invoices and credit notes still open on that day, each posted as a document by post_document() against the suspense account, carrying the balance of the receivable or payable account they fall on, which they must add up to.';

revoke execute on function opening_balance(uuid, uuid, jsonb, boolean, date, jsonb) from public, anon;
grant execute on function opening_balance(uuid, uuid, jsonb, boolean, date, jsonb) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 2. import_books — `20260922120418`, the opening on its day, with its items
-- ---------------------------------------------------------------------------

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
  v_items      integer := 0;
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

    -- 5. The balances, as the opening entry of the year they open, on the day
    --    the books were taken over — the first day of that year or any day
    --    inside it — with the open items the files listed, each a document.
    if v_opening is not null and jsonb_typeof(v_opening) <> 'null' then
      v_year := fiscal_year_at(p_company_id, (v_opening ->> 'date')::date);
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
        p_allow_result_accounts,
        (v_opening ->> 'date')::date,
        (select jsonb_agg((i - 'contact_key') || jsonb_build_object(
                  'contact_id', case when i ->> 'contact_key' is null then null
                                     else v_contacts ->> (i ->> 'contact_key') end))
           from jsonb_array_elements(coalesce(v_opening -> 'items', '[]'::jsonb)) i));
      select e.number into v_opening_no from entries e where e.id = v_opening_id;
      v_lines := v_lines + jsonb_array_length(v_opening -> 'lines');
      v_items := jsonb_array_length(coalesce(v_opening -> 'items', '[]'::jsonb));
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
      'open_items', v_items,
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
  'Takes over books read from another system, whole or not at all: the fiscal years they need (p_open_years), their parties, every entry posted through post_entry() and a trial balance through opening_balance(), on the day the files open it, with the open items they list as documents. Account codes arrive already translated into the company''s chart. p_dry_run does all of it and rolls it back, so the answer and the refusals are the real ones. The same files twice are refused (import_already_done).';
