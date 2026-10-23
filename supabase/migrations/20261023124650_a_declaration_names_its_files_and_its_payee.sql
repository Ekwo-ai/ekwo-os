-- Ekwo OS — a declaration names its files, is paid to somebody, and says so.
--
-- Three gaps of the cycle `docs/filing.md` describes, closed together because
-- an application that walks a declaration from filed to paid meets them one
-- after the other (decision 0087):
--
--   record_filing_files()   the two files of a deposit are named by a
--                           function, not by an update of the deposit
--   tax_payee()             the administration is a contact of the company,
--                           found or created from what the pack names
--   settle_filing()         names that contact when its caller names nobody
--   tax_filings_paid_by_matching
--                           the debt of a declaration matched in full makes
--                           it paid, by whatever path the money was matched
--
-- **Naming the files.** `tax_filing_deposits.sent_file_id` and
-- `acknowledgement_id` were written by an update of the deposit, which its
-- policy allowed under `filings.write` and nothing else checked: a file of
-- another declaration of the same company, a deposit of a declaration a
-- corrective had replaced, a declaration that had not been sent. The function
-- refuses each of them by name. The policy stays, for the archive that loads
-- deposits as they were; an application names files through the function.
--
-- **The administration.** `settle_filing()` carries the net of a period to the
-- account the pack names, and `settle_from_statement()` refuses an open item
-- that names nobody: a payment is made to somebody. So a debt settled without
-- a contact could never be matched to its payment, and the contact had to be
-- one whose third-party account is the pack's — which nothing created. The pack
-- now names the administration (`defaults.tax_payee`, compiled into
-- `country_defaults.tax_payee_name`), and the company's contact for it is the
-- one contact that books to the account the pack names for what a declaration
-- owes. The account is the link: no column on the company, nothing to keep in
-- step, and it is exactly the contact `settle_filing()` would accept.
--
-- **Paid.** `record_filing_outcome(…, 'paid')` existed and nothing called it.
-- A declaration is paid when the debt its settlement carried is matched in
-- full, and that is a fact of the ledger, so it is derived where matching
-- writes it — `entry_lines.matched_amount` — and not left to whoever matched
-- the payment to remember: the bank page, `auto_settle()`, `reconcile()` and an
-- import all meet the same trigger. Unmatching the payment takes it back to
-- accepted.

-- ---------------------------------------------------------------------------
-- 1. What the pack says
-- ---------------------------------------------------------------------------

alter table country_defaults
  add column if not exists tax_payee_name       text,
  add column if not exists tax_payee_source_key text;

comment on column country_defaults.tax_payee_name is
  'The administration a declaration of this country is paid to, by its official name in the pack''s language — the payee of the debt settle_filing() carries to tax_payable_code. tax_payee() creates the company''s contact for it under this name. Null until a pack names one, and then a settlement names nobody unless a contact already books to that account.';
comment on column country_defaults.tax_payee_source_key is
  'The key of the entry of the pack''s source register where the administration''s name is read.';

-- ---------------------------------------------------------------------------
-- 2. record_filing_files
-- ---------------------------------------------------------------------------

create or replace function record_filing_files(
  p_filing_id          uuid,
  p_sent_file_id       uuid default null,
  p_acknowledgement_id uuid default null
)
returns tax_filing_deposits
language plpgsql
volatile
security definer
set search_path = public, pg_temp
as $$
declare
  v_filing  tax_filings;
  v_deposit tax_filing_deposits;
  v_file    record;
  v_id      uuid;
begin
  select * into v_filing from tax_filings f where f.id = p_filing_id;
  if not found or not may_know_of_company(v_filing.company_id) then
    raise exception 'not_found: filing %', p_filing_id using errcode = 'no_data_found';
  end if;

  -- The right of file_filing(): the files are part of the send it recorded.
  if not is_installer() and not has_capability(v_filing.company_id, 'filings.write') then
    raise exception 'not_allowed: naming the files of a declaration in this company needs filings.write'
      using errcode = '42501';
  end if;

  if v_filing.state = 'superseded' then
    raise exception 'filing_superseded: this declaration was replaced by a corrective, and what was sent for it stays as it was; name the files on the corrective';
  end if;

  if p_sent_file_id is null and p_acknowledgement_id is null then
    raise exception 'no_file_named: name the file that was sent, the acknowledgement, or both';
  end if;
  if p_sent_file_id = p_acknowledgement_id then
    raise exception 'same_file_twice: the file that was sent and the acknowledgement that came back are two files';
  end if;

  select * into v_deposit
    from tax_filing_deposits d
   where d.filing_id = p_filing_id
   order by d.sequence desc
   limit 1
   for update;
  if not found then
    raise exception 'filing_not_sent: % has not been sent, so there is no deposit to name its files on; record the send with file_filing() first',
      v_filing.report_code;
  end if;

  -- Each file is an attachment of this declaration. Another company's file and
  -- nobody's get the same words (decision 0065); a file of this company kept
  -- on something else is told where it is.
  foreach v_id in array array_remove(array[p_sent_file_id, p_acknowledgement_id], null) loop
    select a.entity_type, a.entity_id into v_file
      from attachments a where a.id = v_id and a.company_id = v_filing.company_id;
    if not found then
      raise exception 'unknown_attachment: no attachment % in the company of this declaration', v_id
        using errcode = '23503';
    end if;
    if v_file.entity_type is distinct from 'tax_filing' or v_file.entity_id is distinct from p_filing_id then
      raise exception 'attachment_not_of_filing: % is attached to a % and not to this declaration; attach the file to the declaration first',
        v_id, coalesce(v_file.entity_type, 'nothing');
    end if;
  end loop;

  update tax_filing_deposits d
     set sent_file_id       = coalesce(p_sent_file_id, d.sent_file_id),
         acknowledgement_id = coalesce(p_acknowledgement_id, d.acknowledgement_id)
   where d.id = v_deposit.id
  returning * into v_deposit;

  return v_deposit;
end;
$$;

comment on function record_filing_files(uuid, uuid, uuid) is
  'Names the two files of the last send of a declaration: the file that was sent and the acknowledgement that came back, each an attachment of that declaration. A file left null keeps what the deposit named. Asks filings.write, the right of file_filing(), and refuses a declaration that was not sent, one a corrective replaced, and a file kept on something else or in another company.';

revoke execute on function record_filing_files(uuid, uuid, uuid) from public, anon;
grant execute on function record_filing_files(uuid, uuid, uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 3. tax_payee
-- ---------------------------------------------------------------------------

create or replace function tax_payee(p_company_id uuid)
returns contacts
language plpgsql
volatile
security definer
set search_path = public, pg_temp
as $$
declare
  v_name       text;
  v_payable    uuid;
  v_receivable uuid;
  v_country    char(2);
  v_count      integer;
  v_contact    contacts;
begin
  if not may_know_of_company(p_company_id) then
    raise exception 'unknown_company: %', p_company_id using errcode = 'no_data_found';
  end if;
  -- Settling asks filings.write, and finding the administration is part of it.
  if not is_installer() and not has_capability(p_company_id, 'filings.write') then
    raise exception 'not_allowed: finding the administration of this company needs filings.write'
      using errcode = '42501';
  end if;

  select c.fiscal_country, d.tax_payee_name,
         account_id_by_code(c.id, d.tax_payable_code),
         account_id_by_code(c.id, coalesce(d.tax_receivable_code, d.tax_payable_code))
    into v_country, v_name, v_payable, v_receivable
    from companies c
    left join country_defaults d on d.country = c.fiscal_country
   where c.id = p_company_id;

  if v_payable is null then
    raise exception 'no_tax_payable_account: the pack of this company names no account of its chart for what a declaration owes. Set defaults.roles.tax_payable in the pack.';
  end if;

  -- The contact that books to the account is the administration: it is the
  -- only one settle_filing() accepts, so there is nothing else it could be.
  select count(*) into v_count
    from contacts k
   where k.company_id = p_company_id and k.active and k.merged_into is null
     and k.payable_account_id = v_payable;

  if v_count = 1 then
    select * into v_contact
      from contacts k
     where k.company_id = p_company_id and k.active and k.merged_into is null
       and k.payable_account_id = v_payable;
  elsif v_count > 1 then
    -- Several: the one under the pack's name, where there is exactly one.
    select * into v_contact
      from contacts k
     where k.company_id = p_company_id and k.active and k.merged_into is null
       and k.payable_account_id = v_payable
       and lower(btrim(k.name)) = lower(btrim(v_name));
    if v_contact.id is null or (select count(*) from contacts k
                                 where k.company_id = p_company_id and k.active and k.merged_into is null
                                   and k.payable_account_id = v_payable
                                   and lower(btrim(k.name)) = lower(btrim(v_name))) > 1 then
      raise exception 'several_tax_payees: % contacts of this company book to the account of what a declaration owes (%), and none of them alone is the administration. Name it with p_contact_id, or give the others another account.',
        v_count, (select string_agg(k.name, ', ' order by k.name) from contacts k
                   where k.company_id = p_company_id and k.active and k.merged_into is null
                     and k.payable_account_id = v_payable);
    end if;
  else
    -- Nobody yet. A pack that names no administration leaves it unknown, as
    -- filing_deadline() answers null where the pack names no rule.
    if v_name is null then
      return null;
    end if;
    insert into contacts (company_id, name, contact_type, is_company, country,
                          payable_account_id, receivable_account_id, payment_terms_days)
    values (p_company_id, v_name, 'supplier', true, v_country, v_payable, v_receivable, 0)
    returning * into v_contact;
    return v_contact;
  end if;

  -- A credit claimed back is a receivable from the same administration. A
  -- contact that says nothing about that side is given the account the pack
  -- names for it; one that names another account is left as it is, and
  -- settle_filing() says what to change.
  if v_contact.receivable_account_id is null then
    update contacts k set receivable_account_id = v_receivable
     where k.id = v_contact.id
    returning * into v_contact;
  end if;
  return v_contact;
end;
$$;

comment on function tax_payee(uuid) is
  'The contact of this company that is its tax administration: the one contact that books to the account the pack names for what a declaration owes — under the pack''s name where several do — created on first need under the name the pack gives (country_defaults.tax_payee_name), booking both ways to the accounts settle_filing() uses. Null where no contact books to that account and the pack names no administration. Asks filings.write.';

revoke execute on function tax_payee(uuid) from public, anon;
grant execute on function tax_payee(uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 4. settle_filing, which names the administration
--
-- `20260917190000` to the letter, with one step more: a settlement that
-- carries a net and names nobody names the company's administration, found or
-- created by tax_payee(). Naming one explicitly still wins, and is still
-- checked against the account the debt sits on.
-- ---------------------------------------------------------------------------

create or replace function settle_filing(
  p_filing_id  uuid,
  p_credit     tax_credit_treatment default null,
  p_reference  text default null,
  p_contact_id uuid default null,
  p_date       date default null
)
returns entries
language plpgsql
volatile
security invoker
as $$
declare
  v_filing     tax_filings;
  v_country    char(2);
  v_payable    text;
  v_receivable text;
  v_account    uuid;
  v_contact    uuid := p_contact_id;
  v_contact_account uuid;
  v_journal    uuid;
  v_round      money_rounding;
  v_date       date;
  v_label      text;
  v_reference  text;
  v_net        numeric := 0;
  v_seq        integer := 0;
  v_entry      entries;
  r            record;
begin
  select * into v_filing from tax_filings f where f.id = p_filing_id for update;
  if not found then
    raise exception 'not_found: filing %', p_filing_id using errcode = 'no_data_found';
  end if;
  if v_filing.state <> 'accepted' then
    raise exception 'filing_not_accepted: settling follows acceptance, and this one is %', v_filing.state;
  end if;
  if v_filing.settlement_entry_id is not null then
    raise exception 'filing_already_settled: % was settled by entry %',
      p_filing_id, v_filing.settlement_entry_id;
  end if;

  select c.fiscal_country, c.miscellaneous_journal_id
    into v_country, v_journal
    from companies c where c.id = v_filing.company_id;

  if v_journal is null then
    raise exception 'no_miscellaneous_journal: this company has no journal for an entry that belongs to no document. Set defaults.journal_roles.miscellaneous in the pack, which fills country_defaults.misc_journal_code.';
  end if;

  select d.tax_payable_code, d.tax_receivable_code
    into v_payable, v_receivable
    from country_defaults d where d.country = v_country;

  if v_payable is null then
    raise exception 'no_tax_payable_account: the pack of this company names no account for what a declaration owes. Set defaults.roles.tax_payable in the pack, which fills country_defaults.tax_payable_code.';
  end if;

  v_round := rounding_of(v_filing.company_id);
  v_date  := coalesce(p_date, v_filing.period_end);
  v_label := v_filing.report_code || ' ' || v_filing.period_start || ' — ' || v_filing.period_end;
  v_reference := coalesce(p_reference, v_filing.reference);

  if not exists (select 1 from filing_tax_movements(p_filing_id)) then
    raise exception 'nothing_to_settle: % moved no tax account between % and %',
      v_filing.report_code, v_filing.period_start, v_filing.period_end;
  end if;

  select sum(m.balance) into v_net from filing_tax_movements(p_filing_id) m;

  -- A positive net is a debit balance left on the tax accounts, which is a
  -- credit in the company's favour; a negative one is what it owes.
  if v_net > 0 then
    if p_credit is null then
      raise exception 'no_credit_treatment: % to % ends in a credit of %, and what happens to it — carried to the next declaration or claimed back — is this company''s decision',
        v_filing.period_start, v_filing.period_end, v_net;
    end if;
    v_account := account_id_by_code(v_filing.company_id, coalesce(v_receivable, v_payable));
    if v_account is null then
      raise exception 'unknown_tax_account: the pack names % for a credit and this chart has no such account',
        coalesce(v_receivable, v_payable);
    end if;
  else
    if p_credit is not null then
      raise exception 'not_a_credit: this declaration owes money, and a credit treatment does not apply to it';
    end if;
    v_account := account_id_by_code(v_filing.company_id, v_payable);
    if v_account is null then
      raise exception 'unknown_tax_account: the pack names % for what is owed and this chart has no such account',
        v_payable;
    end if;
  end if;

  if not exists (select 1 from accounts a where a.id = v_account and a.reconcilable) then
    raise exception 'tax_account_not_reconcilable: % carries a debt that a payment settles, so the chart has to keep it reconcilable',
      coalesce(case when v_net > 0 then v_receivable end, v_payable);
  end if;

  -- The administration. A net is paid to somebody or by somebody, and a debt
  -- that names nobody is one settle_from_statement() refuses to match: the
  -- caller who names nobody gets the company's administration.
  if v_contact is null and v_net <> 0 then
    v_contact := (tax_payee(v_filing.company_id)).id;
  end if;

  if v_contact is not null then
    v_contact_account := resolve_counterpart_account(v_filing.company_id, v_contact, v_net > 0);
    if v_contact_account <> v_account then
      raise exception 'contact_account_mismatch: the payment of this declaration would be booked on the third-party account of that contact, and the debt sits on %. Set that contact''s account to the one the pack names, or leave the contact out.',
        coalesce(case when v_net > 0 then v_receivable end, v_payable);
    end if;
  end if;

  if exists (select 1 from filing_tax_movements(p_filing_id) m where m.account_id = v_account) then
    raise exception 'tax_account_is_a_posting_account: % is an account the taxes of this period post to, so clearing them into it would leave nothing',
      coalesce(case when v_net > 0 then v_receivable end, v_payable);
  end if;

  insert into entries (company_id, journal_id, fiscal_year_id, entry_date,
                       reference, description, state)
  values (v_filing.company_id, v_journal,
          fiscal_year_at(v_filing.company_id, v_date), v_date,
          v_reference, v_label, 'draft')
  returning * into v_entry;

  for r in select * from filing_tax_movements(p_filing_id) order by account_id loop
    v_seq := v_seq + 10;
    insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit)
    values (v_entry.id, v_filing.company_id, r.account_id, v_seq, v_label,
            case when r.balance < 0 then -r.balance else 0 end,
            case when r.balance > 0 then  r.balance else 0 end);
  end loop;

  if v_net <> 0 then
    insert into entry_lines (entry_id, company_id, account_id, sequence, name,
                             debit, credit, contact_id, date_maturity)
    values (v_entry.id, v_filing.company_id, v_account, v_seq + 10, v_label,
            case when v_net > 0 then  v_net else 0 end,
            case when v_net < 0 then -v_net else 0 end,
            v_contact, v_filing.due_date);
  end if;

  v_entry := post_entry(v_entry.id);

  update tax_filings
     set settlement_entry_id = v_entry.id,
         credit_treatment    = p_credit
   where id = p_filing_id;

  return v_entry;
end;
$$;

comment on function settle_filing(uuid, tax_credit_treatment, text, uuid, date) is
  'Clears the tax accounts a declared period moved and carries the net to the account the pack names for what is owed to the administration — or, where the period ends in a credit, to the one it names for a credit, once the company has said whether it is carried forward or claimed back. One entry per declaration, through post_entry(), with the reference the payment will be matched by. The net names the administration: the contact passed, or else the company''s own, found or created by tax_payee() — matching books a payment, and a payment is made to somebody.';

revoke execute on function settle_filing(uuid, tax_credit_treatment, text, uuid, date) from public, anon;
grant execute on function settle_filing(uuid, tax_credit_treatment, text, uuid, date) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 5. Paid, when the debt is matched
-- ---------------------------------------------------------------------------

create or replace function tax_filings_paid_by_matching()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_filing  tax_filings;
  v_account uuid;
  v_open    numeric;
  v_was     numeric;
begin
  select * into v_filing from tax_filings f where f.settlement_entry_id = new.entry_id;
  if not found or v_filing.state not in ('accepted', 'paid') then
    return null;
  end if;

  -- Only the line that carries the net: the account the pack names for the
  -- side the period ended on. The tax accounts the entry cleared are not it.
  select account_id_by_code(v_filing.company_id,
           case when v_filing.credit_treatment is null then d.tax_payable_code
                else coalesce(d.tax_receivable_code, d.tax_payable_code) end)
    into v_account
    from companies c join country_defaults d on d.country = c.fiscal_country
   where c.id = v_filing.company_id;
  if v_account is distinct from new.account_id then
    return null;
  end if;

  v_open := abs(new.debit - new.credit) - new.matched_amount;
  v_was  := abs(old.debit - old.credit) - old.matched_amount;

  if v_filing.state = 'accepted' and v_open = 0 and v_was > 0 then
    perform record_filing_outcome(v_filing.id, 'paid');
  elsif v_filing.state = 'paid' and v_open > 0 and v_was = 0 then
    -- The payment was unmatched: the debt is open again, and so is the
    -- declaration's money. What the administration said stays said.
    perform record_filing_outcome(v_filing.id, 'accepted');
  end if;
  return null;
end;
$$;

comment on function tax_filings_paid_by_matching() is
  'Records a declaration paid once the line its settlement carried the net on is matched in full, and accepted again when that matching is undone — by whatever path the money was matched: the bank, auto_settle(), reconcile(), an import. Through record_filing_outcome(), so the last send carries the outcome as it would by hand.';

revoke execute on function tax_filings_paid_by_matching() from public, anon, authenticated, service_role;

drop trigger if exists tax_filings_paid_by_matching on entry_lines;
create trigger tax_filings_paid_by_matching
  after update of matched_amount on entry_lines
  for each row
  when (old.matched_amount is distinct from new.matched_amount)
  execute function tax_filings_paid_by_matching();
