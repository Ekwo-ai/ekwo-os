-- Ekwo OS — the administration is named in the company's language.
--
-- `20261023124650` gave the administration a declaration is paid to one name,
-- in the pack's own language (`country_defaults.tax_payee_name`), and
-- `tax_payee()` creates the company's contact for it under that name. In a
-- country of several languages the administration publishes its name in each
-- — SPF Finances, FOD Financiën, FÖD Finanzen — and a company keeping its
-- books in Dutch is paying the FOD Financiën.
--
-- A pack's language file may now carry the name in its language
-- (`i18n/<lang>.json`, `tax_payee`: the name and the register entry it is
-- read in), compiled into `tax_payee_name_i18n`, by language, the way every
-- other label of a pack reaches `name_i18n`. `tax_payee()` creates the contact
-- under the name in the company's language (`companies.language`), and falls
-- back to the pack's own where the pack gives none in it. Where several
-- contacts book to the account, the one under any of the pack's names is the
-- administration: a contact created in another language, or before the pack
-- named it in this one, is still recognised.

alter table country_defaults
  add column if not exists tax_payee_name_i18n jsonb not null default '{}'::jsonb;

comment on column country_defaults.tax_payee_name_i18n is
  'The name of the administration in tax_payee_name, by language, as the administration publishes it in each language of the pack. tax_payee() creates the contact under the company''s language here, else under tax_payee_name.';

create or replace function tax_payee(p_company_id uuid)
returns contacts
language plpgsql
volatile
security definer
set search_path = public, pg_temp
as $$
declare
  v_name       text;
  v_names      text[];
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

  -- The name in the company's language where the pack gives one, else in the
  -- pack's own; and every name the pack gives, by which an existing contact
  -- is recognised whatever language it was created in.
  select c.fiscal_country,
         coalesce(nullif(btrim(d.tax_payee_name_i18n ->> c.language), ''), d.tax_payee_name),
         array_remove(array[lower(btrim(d.tax_payee_name))]
                      || coalesce((select array_agg(lower(btrim(n.value)))
                                     from jsonb_each_text(d.tax_payee_name_i18n) n), '{}'), null),
         account_id_by_code(c.id, d.tax_payable_code),
         account_id_by_code(c.id, coalesce(d.tax_receivable_code, d.tax_payable_code))
    into v_country, v_name, v_names, v_payable, v_receivable
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
    -- Several: the one under a name the pack gives, where there is exactly one.
    select * into v_contact
      from contacts k
     where k.company_id = p_company_id and k.active and k.merged_into is null
       and k.payable_account_id = v_payable
       and lower(btrim(k.name)) = any(v_names);
    if v_contact.id is null or (select count(*) from contacts k
                                 where k.company_id = p_company_id and k.active and k.merged_into is null
                                   and k.payable_account_id = v_payable
                                   and lower(btrim(k.name)) = any(v_names)) > 1 then
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
  'The contact of this company that is its tax administration: the one contact that books to the account the pack names for what a declaration owes — under a name the pack gives, in any of its languages, where several do — created on first need under the name the pack gives in the company''s language (country_defaults.tax_payee_name_i18n), else in the pack''s own (tax_payee_name), booking both ways to the accounts settle_filing() uses. Null where no contact books to that account and the pack names no administration. Asks filings.write.';

revoke execute on function tax_payee(uuid) from public, anon;
grant execute on function tax_payee(uuid) to authenticated, service_role;

revoke execute on all functions in schema public from public;
