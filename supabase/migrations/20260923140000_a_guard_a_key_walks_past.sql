-- Ekwo OS — one guard a machine key walked past.
--
-- Found by sweeping every guard of the schema after `20260922160000` let a key
-- reach the API, because that migration changed what "nobody is signed in"
-- means. It used to mean the installer, on a direct connection, before anybody
-- existed. It now also means a machine key: one arrives as `authenticated`
-- with `auth.uid()` null, by design — a key is not a session.
--
-- So these two lines stopped being the same line:
--
--     if not is_installer() and not has_capability(…, 'company.write') then
--     if auth.uid() is not null and not has_capability(…, 'company.write') then
--
-- The second reads "check the caller, unless there is nobody to check", and
-- with a key there is nobody: the condition is false, the guard never fires,
-- and whoever holds any key of the company walks past it. `is_installer()` is
-- false whenever `ekwo.api_key` is set — *a key is never the installer*,
-- decision 0006 — so the first asks the question of a key too.
--
-- `20260913102115` moved the guards to `is_installer()` for exactly this
-- reason, one release before keys could reach the API. It moved eight of them.
-- `pack_upgrade()` was written after it, in `20260914111907`, and copied the
-- older phrasing from its neighbours.
--
-- **What it allowed.** `pack_upgrade()` is SECURITY DEFINER and executable by
-- `authenticated`, so with `p_apply` it moves a company onto another version
-- of its country pack — the chart of accounts, the taxes and where each one
-- posts, the boxes of the declaration form — and it asks for `company.write`.
-- A key holding nothing but `entries.read` was answered, and the refusal never
-- came. Verified by calling it rather than by reading it:
--
--     has_capability(company, 'company.write') = false
--     pack_upgrade(company, country, p_apply := true) -> answered
--
-- Nothing was in reach to change in that test, because the company was already
-- at the version the installation holds. That is luck, not a defence.
--
-- Every other guard was swept the same way, against the bodies the database
-- actually holds rather than against the migrations that wrote them — a
-- function is republished, and only the last definition is the one that runs.
-- Seven functions test whether `auth.uid()` is null; six were right.
-- `accept_invitation()` and `set_preferences()` raise when it is null, so a key
-- is refused. `entries_guard_posted()` asks for a signed-in user *and* the
-- capability before allowing, so a key fails it and is refused. `is_installer()`
-- itself, and the two functions of `20260922161500` and `20260922162500`, ask
-- the question in the direction that makes a key a caller rather than an
-- absence.
--
-- Only the guard below had it the other way round.

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
  if v_country is null then
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

comment on function pack_upgrade(uuid, character, boolean) is
  'Moves a company onto the pack version this installation holds, or lists what it would do with p_apply false. Needs company.write, of a signed-in member or of the machine key presented — the installer alone is exempt, and a key is never the installer.';

revoke execute on all functions in schema public from public;

revoke execute on function pack_upgrade(uuid, character, boolean) from public, anon;
grant execute on function pack_upgrade(uuid, character, boolean) to authenticated, service_role;
