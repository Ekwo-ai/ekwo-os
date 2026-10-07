-- ---------------------------------------------------------------------------
-- A shared instance keeps its tenants apart
-- ---------------------------------------------------------------------------
-- Decision 0001 says one installation is one customer, and every instance-level
-- rule of this schema was written from it: the first signed-in user may claim
-- an installation nobody administers, a company nobody is a member of is
-- claimed by whoever arrives first, and a handful of definer helpers answer
-- about any company whose id they are given. On an installation that is one
-- customer's, each of those is a convenience.
--
-- An operator may also host one installation for several unrelated people —
-- a trial, where each person keeps a company of their own on an instance the
-- operator runs. There, the same conveniences are leaks. Decision 0065 adds a
-- setting of the installation, **shared**, off by default, so that nothing
-- changes for an installation that is one customer's; turned on by the
-- installer or an instance administrator, it changes exactly this:
--
--   1. A signed-in person may create a company of their own with
--      `create_company()`, owned by them and nobody else, up to
--      `companies_per_person` — counted under a lock on the person. A machine
--      key never may: who owns a company is a membership, and a key does not
--      choose it (decision 0064). Off, creating a company stays an
--      instance-level act, as before.
--   2. A company with no member is no longer claimed by whoever arrives:
--      `company_has_no_member()` answers false to anybody but the installer
--      and an instance administrator, which closes the third branch of the
--      insert policy on `company_members` — and the answer itself, which said
--      whether a company of a given id exists.
--   3. `module_is_enabled()`, `module_settings()` and `preferred_languages()`
--      answer about a company only to whoever may know of it: one of its
--      members, a key of it, an instance administrator, the installer. To
--      anybody else they answer as for a company that does not exist.
--   4. `share_document()`, `revoke_share()`, `revoke_api_key()` and
--      `revoke_invitation()` say *unknown* for a row of a company the caller
--      may not know of, as they do for a row that does not exist, rather than
--      *not allowed*, which said that it does.
--
-- What it does not change: what a member of a company may do in it, what a
-- key may do, and what an instance administrator may do — on a shared
-- instance the administrator is the operator, who reaches every company
-- anyway. An operator hosting people therefore never lets a person be an
-- administrator of the shared instance; the installation claims its first
-- administrator before anybody else can (`claim_instance_admin()`).
-- ---------------------------------------------------------------------------

-- ---------------------------------------------------------------------------
-- 1. The setting
-- ---------------------------------------------------------------------------

alter table instance
  add column if not exists shared boolean not null default false,
  add column if not exists companies_per_person integer;

alter table instance
  drop constraint if exists instance_companies_per_person_range;
alter table instance
  add constraint instance_companies_per_person_range check (
    companies_per_person is null or companies_per_person between 0 and 1000
  );

alter table instance
  drop constraint if exists instance_shared_says_how_many;
alter table instance
  add constraint instance_shared_says_how_many check (
    not shared or companies_per_person is not null
  );

comment on column instance.shared is
  'Whether this installation is shared by several unrelated people, each with companies of their own (decision 0065). Off by default: an installation is one customer''s.';
comment on column instance.companies_per_person is
  'On a shared installation, how many companies one signed-in person may create and own. Null when the installation is not shared.';

-- Definer: a person with no company yet cannot read the instance row, and is
-- exactly who asks whether they may create one.
create or replace function instance_is_shared()
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select coalesce((select i.shared from instance i where i.id = 1), false);
$$;

comment on function instance_is_shared() is
  'Whether this installation is shared by several unrelated people (decision 0065). False on an installation with no instance row yet.';

create or replace function instance_sharing()
returns table (shared boolean, companies_per_person integer)
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select coalesce(i.shared, false), i.companies_per_person
    from (select 1) one
    left join instance i on i.id = 1;
$$;

comment on function instance_sharing() is
  'Whether this installation is shared, and how many companies one person may create on it. Says nothing about anybody''s companies.';

create or replace function share_instance(p_companies_per_person integer)
returns instance
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_old instance%rowtype;
  v_row instance%rowtype;
begin
  if not is_installer() and not is_instance_admin() then
    raise exception 'not_instance_admin: sharing an installation is an instance-level act'
      using errcode = '42501';
  end if;
  if p_companies_per_person is null or p_companies_per_person not between 0 and 1000 then
    raise exception 'bad_companies_per_person: a shared installation says how many companies one person may create, from 0 to 1000';
  end if;
  select * into v_old from instance where id = 1;
  if v_old.id is null then
    raise exception 'instance_not_initialised: run init_instance() first';
  end if;

  update instance
     set shared = true, companies_per_person = p_companies_per_person, updated_at = now()
   where id = 1
  returning * into v_row;

  perform audit_record(
    null, 'instance', v_row.instance_id, v_row.organization_name, 'update', 'instance_shared',
    jsonb_build_object('shared', v_old.shared, 'companies_per_person', v_old.companies_per_person),
    jsonb_build_object('shared', v_row.shared, 'companies_per_person', v_row.companies_per_person));
  return v_row;
end;
$$;

comment on function share_instance(integer) is
  'Turns the shared setting on (decision 0065): a signed-in person may create up to this many companies of their own, and nobody learns of a company they may not know of. The installer or an instance administrator.';

create or replace function unshare_instance()
returns instance
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_old instance%rowtype;
  v_row instance%rowtype;
begin
  if not is_installer() and not is_instance_admin() then
    raise exception 'not_instance_admin: sharing an installation is an instance-level act'
      using errcode = '42501';
  end if;
  select * into v_old from instance where id = 1;
  if v_old.id is null then
    raise exception 'instance_not_initialised: run init_instance() first';
  end if;

  update instance
     set shared = false, companies_per_person = null, updated_at = now()
   where id = 1
  returning * into v_row;

  perform audit_record(
    null, 'instance', v_row.instance_id, v_row.organization_name, 'update', 'instance_unshared',
    jsonb_build_object('shared', v_old.shared, 'companies_per_person', v_old.companies_per_person),
    jsonb_build_object('shared', v_row.shared, 'companies_per_person', v_row.companies_per_person));
  return v_row;
end;
$$;

comment on function unshare_instance() is
  'Turns the shared setting off: the installation is one customer''s again, and creating a company an instance-level act. The installer or an instance administrator.';

-- ---------------------------------------------------------------------------
-- 2. Who may know of a company
-- ---------------------------------------------------------------------------

create or replace function may_know_of_company(p_company_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select not instance_is_shared()
      or is_installer()
      or is_instance_admin()
      or is_company_member(p_company_id);
$$;

comment on function may_know_of_company(uuid) is
  'Whether the caller may learn anything of this company, even that it exists: always on an installation that is not shared; on a shared one, its members, a key of it, an instance administrator and the installer (decision 0065).';

create or replace function company_has_no_member(p_company_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select (not instance_is_shared() or is_installer() or is_instance_admin())
     and not exists (select 1 from company_members m where m.company_id = p_company_id);
$$;

comment on function company_has_no_member(uuid) is
  'Whether a company has no member yet, which lets its first member claim it. On a shared installation only the installer and an instance administrator are told, and claim (decision 0065).';

create or replace function module_is_enabled(p_company_id uuid, p_code text)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select may_know_of_company(p_company_id)
     and exists (
       select 1 from company_modules m
        where m.company_id = p_company_id and m.module_code = p_code
     );
$$;

comment on function module_is_enabled(uuid, text) is
  'Whether a module is enabled on a company. Definer so a policy on company_modules cannot recurse into it. On a shared installation, false to a caller who may not know of the company (decision 0065).';

create or replace function module_settings(p_company_id uuid, p_code text)
returns jsonb
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select m.settings
    from company_modules m
   where m.company_id = p_company_id and m.module_code = p_code
     and may_know_of_company(p_company_id);
$$;

comment on function module_settings(uuid, text) is
  'The settings a company keeps for one of its modules, or null when the module is not enabled. The socle never looks inside the object. On a shared installation, null to a caller who may not know of the company (decision 0065).';

create or replace function preferred_languages(p_language text, p_company_id uuid)
returns text[]
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select array_remove(array[
    p_language,
    (select c.language from companies c where c.id = p_company_id and may_know_of_company(p_company_id)),
    (select d.language_default
       from companies c join country_defaults d on d.country = c.country
      where c.id = p_company_id and may_know_of_company(p_company_id))
  ], null);
$$;

comment on function preferred_languages(text, uuid) is
  'The languages to try, in order, from a starting point the caller names: that one, then the company''s, then the one the country pack declares. Feed it to label_for(). On a shared installation the company''s are left out for a caller who may not know of it (decision 0065).';

-- ---------------------------------------------------------------------------
-- 3. Creating a company of one's own
-- ---------------------------------------------------------------------------

-- Definer now: on a shared installation a person creates a company they are
-- not yet a member of, which neither the insert policy on `companies` nor the
-- one on `company_members` lets them do, and the guard below is the whole of
-- the rule — for an administrator and the installer, exactly what it was.
create or replace function create_company(
  p_name              text,
  p_country           char(2),
  p_currency_code     char(3) default null,
  p_language          char(2) default null,
  p_chart_code        text    default null,
  p_fiscal_year       integer default null,
  p_fiscal_year_start date    default null,
  p_owner_user_id     uuid    default null
)
returns companies
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_defaults country_defaults%rowtype;
  v_currency char(3);
  v_language char(2);
  v_owner    uuid := coalesce(p_owner_user_id, auth.uid());
  v_year     integer := coalesce(p_fiscal_year, extract(year from coalesce(p_fiscal_year_start, current_date))::integer);
  v_bounds   record;
  v_company  companies%rowtype;
  v_sharing  record;
  v_owned    integer;
begin
  if not is_installer() and not is_instance_admin() then
    select * into v_sharing from instance_sharing();
    if not v_sharing.shared then
      raise exception 'not_instance_admin: creating a company is an instance-level act'
        using errcode = '42501';
    end if;
    -- A person, in their own session. A key does not choose who owns a company.
    if auth.uid() is null or nullif(current_setting('ekwo.api_key', true), '') is not null then
      raise exception 'not_allowed: a company of one''s own is created by a signed-in person, in their own session'
        using errcode = '42501';
    end if;
    if p_owner_user_id is not null and p_owner_user_id is distinct from auth.uid() then
      raise exception 'not_allowed: a company of one''s own is owned by whoever creates it'
        using errcode = '42501';
    end if;
    v_owner := auth.uid();
    perform pg_advisory_xact_lock(hashtextextended('ekwo.create_company:' || v_owner::text, 0));
    select count(*) into v_owned
      from company_members m
     where m.user_id = v_owner and m.role = 'owner';
    if v_owned >= v_sharing.companies_per_person then
      raise exception 'company_limit: this installation lets one person create % compan%, and you own %',
        v_sharing.companies_per_person,
        case when v_sharing.companies_per_person = 1 then 'y' else 'ies' end,
        v_owned
        using errcode = '42501';
    end if;
  end if;

  select * into v_defaults from country_defaults where country = p_country;

  -- The currency and the language have to be settled before the insert: both
  -- columns are not null with a default, so there is no later moment at which
  -- they are empty and the pack could fill them. The pack answers, or the
  -- caller does, and there is no third answer written here.
  v_currency := upper(coalesce(p_currency_code, v_defaults.currency_code));
  if v_currency is null then
    raise exception 'no_currency: the % pack names no currency; name one', p_country;
  end if;
  v_language := lower(coalesce(p_language, v_defaults.language_default));
  if v_language is null then
    raise exception 'no_language: the % pack names no language for its labels; name one', p_country;
  end if;

  select * into v_bounds from fiscal_year_bounds(p_country, v_year, p_fiscal_year_start);

  insert into companies (name, country, fiscal_country, currency_code, language)
  values (p_name, p_country, p_country, v_currency, v_language)
  returning * into v_company;

  if v_owner is not null then
    insert into company_members (company_id, user_id, role)
    values (v_company.id, v_owner, 'owner')
    on conflict (company_id, user_id) do nothing;
  end if;

  perform install_country_template(v_company.id, p_country, v_language, p_chart_code);

  insert into fiscal_years (company_id, name, start_date, end_date)
  values (v_company.id, 'FY' || v_year::text, v_bounds.start_date, v_bounds.end_date);

  select * into v_company from companies where id = v_company.id;
  return v_company;
end;
$$;

comment on function create_company(text, char, char, char, text, integer, date, uuid) is
  'Creates a company, makes its owner the first member, copies the country pack into it and opens its first financial year on the month that pack declares. An instance-level act; on a shared installation, also a signed-in person''s for a company of their own, up to companies_per_person (decision 0065).';

-- ---------------------------------------------------------------------------
-- 4. Unknown, rather than not allowed
-- ---------------------------------------------------------------------------

create or replace function share_document(p_document_id uuid, p_expires_at timestamp with time zone default NULL::timestamp with time zone)
returns table (share_id uuid, token text, url text)
language plpgsql
security definer
set search_path = public, pg_temp
as $function$
declare
  v_doc     documents%rowtype;
  v_refusal text;
  v_token   text;
  v_base    text;
  v_row     document_shares%rowtype;
begin
  select * into v_doc from documents where id = p_document_id;
  if v_doc.id is null or not may_know_of_company(v_doc.company_id) then
    raise exception 'unknown_document: document % does not exist', p_document_id;
  end if;

  if not is_installer() and not has_capability(v_doc.company_id, 'documents.share') then
    raise exception 'not_allowed: publishing a document of this company needs documents.share'
      using errcode = '42501';
  end if;

  v_refusal := document_share_refusal(v_doc);
  if v_refusal is not null then
    raise exception '%', v_refusal;
  end if;

  if p_expires_at is not null and p_expires_at <= now() then
    raise exception 'share_expires_in_the_past: % is not in the future, so this link would be born dead',
      p_expires_at;
  end if;

  -- 32 bytes as base64url, 43 characters, no padding. `translate` maps the two
  -- characters base64 and base64url disagree on and drops the `=`, whose
  -- position is implied by the length.
  v_token := translate(
    encode(
      decode(replace(gen_random_uuid()::text, '-', '') ||
             replace(gen_random_uuid()::text, '-', ''), 'hex'),
      'base64'),
    '+/=', '-_');

  insert into document_shares (company_id, subject_kind, document_id, token_hash,
                               expires_at, created_by)
  values (v_doc.company_id, 'document', v_doc.id,
          encode(sha256(convert_to(v_token, 'UTF8')), 'hex'),
          p_expires_at, acting_user())
  returning * into v_row;

  perform audit_record(
    v_doc.company_id, 'document_shares', v_row.id,
    coalesce(v_doc.number, v_doc.id::text), 'insert', 'document_shared',
    null,
    jsonb_build_object('document_id', v_doc.id, 'doc_type', v_doc.doc_type,
                       'expires_at', v_row.expires_at));

  select i.public_base_url into v_base from instance i where i.id = 1;

  return query select v_row.id,
                      v_token,
                      case when v_base is null then null
                           else rtrim(v_base, '/') || '/shared/' || v_token end;
end;
$function$;

create or replace function revoke_share(p_share_id uuid)
returns document_shares
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_row document_shares%rowtype;
begin
  select * into v_row from document_shares where id = p_share_id;
  if v_row.id is null or not may_know_of_company(v_row.company_id) then
    raise exception 'unknown_share: no share with that id';
  end if;

  if not is_installer() and not has_capability(v_row.company_id, 'documents.share') then
    raise exception 'not_allowed: withdrawing a link of this company needs documents.share'
      using errcode = '42501';
  end if;

  update document_shares
     set revoked_at = coalesce(revoked_at, now())
   where id = p_share_id
  returning * into v_row;

  perform audit_record(
    v_row.company_id, 'document_shares', v_row.id,
    (select coalesce(d.number, d.id::text) from documents d where d.id = v_row.document_id),
    'update', 'document_share_revoked',
    null, jsonb_build_object('revoked_at', v_row.revoked_at));

  return v_row;
end;
$$;

create or replace function revoke_api_key(p_api_key_id uuid)
returns api_keys
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_row api_keys%rowtype;
begin
  select * into v_row from api_keys where id = p_api_key_id;
  if v_row.id is null or not may_know_of_company(v_row.company_id) then
    raise exception 'unknown_api_key: no key with that id';
  end if;
  if not is_installer() and not has_capability(v_row.company_id, 'members.manage') then
    raise exception 'not_allowed: withdrawing a key needs members.manage'
      using errcode = '42501';
  end if;

  update api_keys set revoked_at = coalesce(revoked_at, now())
   where id = p_api_key_id
  returning * into v_row;

  return v_row;
end;
$$;

create or replace function revoke_invitation(p_invitation_id uuid)
returns company_invitations
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_row company_invitations%rowtype;
begin
  select * into v_row from company_invitations where id = p_invitation_id;
  if v_row.id is null or not may_know_of_company(v_row.company_id) then
    raise exception 'unknown_invitation: no invitation with that id';
  end if;

  if not is_installer() and not has_capability(v_row.company_id, 'members.manage')
     and not is_instance_admin() then
    raise exception 'not_allowed: withdrawing an invitation needs members.manage'
      using errcode = '42501';
  end if;

  if v_row.accepted_at is not null then
    raise exception 'invitation_already_accepted: it became a membership on %; remove the member instead',
      v_row.accepted_at;
  end if;

  update company_invitations set revoked_at = coalesce(revoked_at, now())
   where id = p_invitation_id
  returning * into v_row;

  return v_row;
end;
$$;

-- `pack_upgrade()` is the one function taking a company that said
-- `unknown_company` for an id nobody holds and `not_allowed` for a company
-- the caller may not change: `tests/shared_instance.test.ts` calls every
-- function of that shape both ways and found it. Its body is unchanged but
-- for the first test.
create or replace function pack_upgrade(
  p_company_id uuid,
  p_country    char(2) default null,
  p_apply      boolean default false
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_country   char(2);
  v_chart     text;
  v_from      text;
  v_to        text;
  v_applied   jsonb := '[]'::jsonb;
  v_listed    jsonb := '[]'::jsonb;
  v_refused   jsonb := '[]'::jsonb;
  d           record;
  v_tax_id    uuid;
  v_template  tax_templates%rowtype;
begin
  select coalesce(p_country, c.country) into v_country
    from companies c where c.id = p_company_id;
  if v_country is null or not may_know_of_company(p_company_id) then
    raise exception 'unknown_company: %', p_company_id;
  end if;

  if not is_installer() and not has_capability(p_company_id, 'company.write') then
    raise exception 'not_allowed: upgrading a country pack needs company.write';
  end if;

  select cp.version, cp.chart_code into v_from, v_chart
    from company_packs cp
   where cp.company_id = p_company_id and cp.country = v_country;
  if v_chart is null then
    raise exception 'no_pack_installed: company % holds no % pack, so there is nothing to upgrade from', p_company_id, v_country;
  end if;

  select version into v_to from country_packs where country = v_country;
  if v_to is null then
    raise exception 'no_pack_loaded: this installation holds no % pack. Apply the seeds of this release first.', v_country;
  end if;

  for d in select * from pack_upgrade_diff(p_company_id, v_country) loop
    -- Never, whatever the caller asked. An upgrade adds and closes; it does
    -- not take a row out of a company's books.
    if d.change = 'company_only' then
      v_refused := v_refused || jsonb_build_object('object', d.object, 'key', d.key,
                                                   'change', d.change, 'rule', d.rule,
                                                   'detail', d.detail);
      continue;
    end if;

    if d.rule = 'review' and not p_apply then
      v_listed := v_listed || jsonb_build_object('object', d.object, 'key', d.key,
                                                 'change', d.change, 'rule', d.rule,
                                                 'detail', d.detail);
      continue;
    end if;

    if d.object = 'account' and d.change = 'missing' then
      insert into accounts (company_id, code, name, name_i18n, statement_hint, account_type, reconcilable)
      select p_company_id, t.code, label_for(t.name, t.name_i18n, preferred_languages(p_company_id)),
             t.name_i18n, t.statement_hint, t.account_type, t.reconcilable
        from account_templates t
       where t.country = v_country and t.chart_code = v_chart and t.code = d.key
      on conflict (company_id, code) do nothing;

    elsif d.object = 'account' and d.change = 'differs' then
      update accounts a
         set name = label_for(t.name, t.name_i18n, preferred_languages(p_company_id)),
             name_i18n = t.name_i18n,
             account_type = t.account_type
        from account_templates t
       where t.country = v_country and t.chart_code = v_chart and t.code = a.code
         and a.company_id = p_company_id and a.code = d.key;

    elsif d.object = 'journal' and d.change = 'missing' then
      insert into journals (company_id, code, name, journal_type)
      select p_company_id, t.code, t.name, t.journal_type
        from journal_templates t
       where t.country = v_country and t.code = d.key
      on conflict (company_id, code) do nothing;

    elsif d.object = 'journal' and d.change = 'differs' then
      update journals j
         set name = t.name, journal_type = t.journal_type
        from journal_templates t
       where t.country = v_country and t.code = j.code
         and j.company_id = p_company_id and j.code = d.key;

    elsif d.object = 'tax' and d.change = 'missing' then
      select * into v_template from tax_templates where country = v_country and code = d.key;
      insert into taxes (company_id, code, name, description, amount_type, amount,
                         applies_to, treatment, country, valid_from, valid_to,
                         legal_reference, vat_category, exemption_code, sequence,
                         tax_kind, recoverable, jurisdiction, price_include,
                         cash_basis, cash_basis_transition_account_id,
                         applies_seller_territory, applies_buyer_territory,
                         applies_supply_territory, applies_supply_vs_seller)
      values (p_company_id, v_template.code, v_template.name, v_template.description,
              v_template.amount_type, v_template.amount, v_template.applies_to,
              v_template.treatment, v_country, v_template.valid_from, v_template.valid_to,
              v_template.legal_reference, v_template.vat_category, v_template.exemption_code,
              v_template.sequence, v_template.tax_kind, v_template.recoverable,
              v_template.jurisdiction, v_template.price_include, v_template.cash_basis,
              account_id_by_code(p_company_id, v_template.cash_basis_transition_account_code),
              v_template.applies_seller_territory, v_template.applies_buyer_territory,
              v_template.applies_supply_territory, v_template.applies_supply_vs_seller)
      on conflict (company_id, code) do nothing
      returning id into v_tax_id;

      if v_tax_id is not null then
        insert into tax_postings (tax_id, company_id, document_kind, posting_type,
                                  factor_percent, account_id, declaration_box,
                                  declaration_boxes, box_factor_percent, report_code,
                                  sequence)
        select v_tax_id, p_company_id, tp.document_kind, tp.posting_type,
               tp.factor_percent, account_id_by_code(p_company_id, tp.account_code),
               tp.declaration_box, tp.declaration_boxes, tp.box_factor_percent,
               tp.report_code, tp.sequence
          from tax_posting_templates tp
         where tp.tax_template_id = v_template.id
         order by tp.sequence;
      end if;

    elsif d.object = 'tax' and d.change = 'valid_to' then
      update taxes x
         set valid_to = t.valid_to
        from tax_templates t
       where t.country = v_country and t.code = x.code
         and x.company_id = p_company_id and x.code = d.key;

    elsif d.object = 'tax' and d.change = 'differs' then
      update taxes x
         set name = t.name, description = t.description, amount = t.amount,
             amount_type = t.amount_type, applies_to = t.applies_to,
             treatment = t.treatment, valid_from = t.valid_from,
             legal_reference = t.legal_reference, vat_category = t.vat_category,
             exemption_code = t.exemption_code, tax_kind = t.tax_kind,
             recoverable = t.recoverable, jurisdiction = t.jurisdiction,
             price_include = t.price_include, cash_basis = t.cash_basis,
             applies_seller_territory = t.applies_seller_territory,
             applies_buyer_territory = t.applies_buyer_territory,
             applies_supply_territory = t.applies_supply_territory,
             applies_supply_vs_seller = t.applies_supply_vs_seller
        from tax_templates t
       where t.country = v_country and t.code = x.code
         and x.company_id = p_company_id and x.code = d.key;

    elsif d.object = 'tax_posting' and d.change = 'differs' then
      select id into v_tax_id from taxes where company_id = p_company_id and code = d.key;
      delete from tax_postings where tax_id = v_tax_id;
      insert into tax_postings (tax_id, company_id, document_kind, posting_type,
                                factor_percent, account_id, declaration_box,
                                declaration_boxes, box_factor_percent, report_code,
                                sequence)
      select v_tax_id, p_company_id, tp.document_kind, tp.posting_type,
             tp.factor_percent, account_id_by_code(p_company_id, tp.account_code),
             tp.declaration_box, tp.declaration_boxes, tp.box_factor_percent,
             tp.report_code, tp.sequence
        from tax_posting_templates tp
        join tax_templates t on t.id = tp.tax_template_id
       where t.country = v_country and t.code = d.key
       order by tp.sequence;

    else
      -- A difference this function does not know how to apply is listed
      -- rather than guessed at. Raising here would make a new kind of
      -- difference break every upgrade.
      v_listed := v_listed || jsonb_build_object('object', d.object, 'key', d.key,
                                                 'change', d.change, 'rule', d.rule,
                                                 'detail', d.detail);
      continue;
    end if;

    v_applied := v_applied || jsonb_build_object('object', d.object, 'key', d.key,
                                                 'change', d.change, 'rule', d.rule,
                                                 'detail', d.detail);
  end loop;

  -- The version moves only when nothing is left waiting. A company that still
  -- holds a difference it has not decided on has not finished upgrading, and
  -- saying otherwise would hide the difference at the next run.
  if jsonb_array_length(v_listed) = 0 then
    update company_packs
       set version = v_to, upgraded_at = now()
     where company_id = p_company_id and country = v_country;
  end if;

  perform audit_record(
    p_company_id, 'company_packs', null, v_country, 'update', 'pack_upgraded',
    jsonb_build_object('version', v_from),
    jsonb_build_object('version', case when jsonb_array_length(v_listed) = 0 then v_to else v_from end,
                       'pack_version', v_to,
                       'chart_code', v_chart,
                       'applied', v_applied,
                       'listed', v_listed,
                       'never_applied', v_refused));

  return jsonb_build_object(
    'company_id', p_company_id,
    'country', v_country,
    'chart_code', v_chart,
    'from_version', v_from,
    'to_version', v_to,
    'version_moved', jsonb_array_length(v_listed) = 0,
    'applied', v_applied,
    'listed', v_listed,
    'never_applied', v_refused);
end;
$$;

-- `unpost_document()`, found the same way by the sweep of the functions that
-- take the id of a row: unchanged but for its first test.
create or replace function unpost_document(p_document_id uuid)
returns documents
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_doc     documents%rowtype;
  v_entry   entries%rowtype;
  v_refusal text;
  v_format  text;
  v_code    text;
  v_period  smallint;
  v_last    integer;
  v_is_last boolean;
begin
  select * into v_doc from documents where id = p_document_id for update;
  if not found or not may_know_of_company(v_doc.company_id) then
    raise exception 'unknown_document: document % does not exist', p_document_id;
  end if;

  -- Definer: the caller is asked here, before anything is read on their behalf.
  if not is_installer() and not has_capability(v_doc.company_id, 'documents.post') then
    raise exception 'not_allowed: putting a posted document back to draft in this company needs documents.post'
      using errcode = '42501';
  end if;

  select * into v_entry from entries where id = v_doc.entry_id for update;

  -- The counter is held until the transaction ends, so that "the last number
  -- drawn" is still true when it is given back.
  if found then
    select r.number_format into v_format from numbering_rules(v_doc.company_id) r;
    select j.code into v_code from journals j where j.id = v_entry.journal_id;
    v_period := case when v_format ~ '\{(YYYY|YY)\}'
                     then extract(year from v_entry.entry_date)::smallint
                     else 0::smallint end;
    select s.last_number into v_last
      from journal_sequences s
     where s.journal_id = v_entry.journal_id and s.year = v_period
       for update;
  end if;

  v_refusal := unpost_refusal(p_document_id);
  if v_refusal is not null then
    raise exception '%', v_refusal
      using errcode = case split_part(v_refusal, ':', 1)
                        when 'not_allowed' then '42501'
                        when 'document_period_closed' then '55006'
                        when 'document_declared' then '55006'
                        else 'P0001'
                      end;
  end if;

  v_is_last := v_last is not null
               and v_entry.number = format_number(v_format, v_code, v_entry.entry_date, v_last);

  insert into document_unpostings (company_id, document_id, doc_type, entry_id, entry_number,
                                   journal_id, entry_date, number_returned)
  values (v_doc.company_id, v_doc.id, v_doc.doc_type, v_entry.id, v_entry.number,
          v_entry.journal_id, v_entry.entry_date, v_is_last);

  -- Back to what it was before post_document(): what posting derived goes,
  -- what was keyed stays.
  update documents
     set state = 'draft',
         entry_id = null,
         number = case when number is not distinct from v_entry.number then null else number end,
         accounting_date = case when accounting_date is not distinct from document_date
                                then null else accounting_date end,
         tax_point_date = case when tax_point_date is not distinct from
                                    tax_point_of(company_id, document_date, delivery_date, null)
                               then null else tax_point_date end,
         seller_territory_code     = null,
         buyer_territory_code      = null,
         supply_territory_resolved = null
   where id = v_doc.id
  returning * into v_doc;

  -- Its lines and their analytic split go with it, by the foreign keys.
  delete from entries where id = v_entry.id;

  if v_is_last then
    update journal_sequences
       set last_number = last_number - 1
     where journal_id = v_entry.journal_id and year = v_period and last_number = v_last;
  end if;

  return v_doc;
end;
$$;

-- `catch_up_journal_sequence()` and `next_entry_number()`, which take a
-- journal: unchanged but for their first test.
create or replace function catch_up_journal_sequence(p_journal_id uuid, p_date date, p_number text)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_company uuid;
  v_format  text;
  v_period  smallint;
  v_counter integer;
begin
  select j.company_id into v_company from journals j where j.id = p_journal_id;
  if v_company is null or not may_know_of_company(v_company) then
    return;
  end if;

  if not is_installer() and not has_capability(v_company, 'entries.post') then
    raise exception 'not_allowed: moving a counter in this company needs entries.post'
      using errcode = '42501';
  end if;

  select number_format into v_format from numbering_rules(v_company);
  v_counter := number_counter(v_format, p_number);
  if v_counter is null then
    return;
  end if;

  v_period := case when v_format ~ '\{(YYYY|YY)\}'
                   then extract(year from p_date)::smallint
                   else 0::smallint end;

  insert into journal_sequences (journal_id, year, last_number)
  values (p_journal_id, v_period, v_counter)
  on conflict (journal_id, year)
    do update set last_number = greatest(journal_sequences.last_number, excluded.last_number);
end;
$$;

create or replace function next_entry_number(p_journal_id uuid, p_date date)
returns text
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_code    text;
  v_company uuid;
  v_format  text;
  v_period  smallint;
  v_number  integer;
begin
  select j.code, j.company_id into v_code, v_company from journals j where j.id = p_journal_id;
  if v_code is null or not may_know_of_company(v_company) then
    raise exception 'unknown_journal: journal % does not exist', p_journal_id;
  end if;

  if not is_installer() and not has_capability(v_company, 'entries.post') then
    raise exception 'not_allowed: drawing a number in this company needs entries.post'
      using errcode = '42501';
  end if;

  select number_format into v_format from numbering_rules(v_company);
  if v_format is null or v_format = '' then
    raise exception 'no_number_format: the country pack of this company declares no documents.number_format, and there is no default to fall back on';
  end if;

  -- A pattern that carries the year restarts with it; one that does not is a
  -- single series, kept under the period that is not a year.
  v_period := case when v_format ~ '\{(YYYY|YY)\}'
                   then extract(year from p_date)::smallint
                   else 0::smallint end;

  insert into journal_sequences (journal_id, year, last_number)
  values (p_journal_id, v_period, 1)
  on conflict (journal_id, year)
    do update set last_number = journal_sequences.last_number + 1
  returning last_number into v_number;

  return format_number(v_format, v_code, p_date, v_number);
end;
$$;

-- ---------------------------------------------------------------------------
-- Grants
-- ---------------------------------------------------------------------------

-- Every function redefined above keeps the grants it had: `create or replace`
-- does not touch them. The new ones are a signed-in user's, as every callable
-- function of this schema is; none is the anonymous role's.

revoke execute on all functions in schema public from public;

grant execute on function instance_is_shared() to authenticated, service_role;
grant execute on function instance_sharing() to authenticated, service_role;
grant execute on function share_instance(integer) to authenticated, service_role;
grant execute on function unshare_instance() to authenticated, service_role;
grant execute on function may_know_of_company(uuid) to authenticated, service_role;
