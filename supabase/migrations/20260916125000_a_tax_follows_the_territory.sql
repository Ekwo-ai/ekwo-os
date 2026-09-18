-- Ekwo OS — a tax follows the territory of the parties.
--
-- Two packs stopped at this wall from opposite sides, and `docs/international.md`
-- records both. `packs/gb/` cannot carry the Northern Ireland taxes, because a
-- company in Manchester would be offered them; `packs/us/` offers a Californian
-- company the New York and Oregon codes, because `jurisdiction` is a label on
-- the tax and nothing reads it. Both notes proposed the same fix — let a tax
-- name a territory, and let a party record the one it is in — and the American
-- one added the half the British one did not need: a sale is taxed where the
-- goods are delivered, so the condition is on the **buyer** and on the place of
-- supply, not only on the seller.
--
-- The whole argument, with the three shapes weighed against this one, is in
-- `docs/decisions.md`, "A tax follows the territory of the parties". What
-- follows is the schema.
--
-- ---------------------------------------------------------------------------
-- A territory is a column, not a composition
-- ---------------------------------------------------------------------------
--
-- A company and a contact each carry a country, and a country is not a
-- territory: the tax that matters here is levied by California and not by the
-- United States, and Northern Ireland is `XI` — a code of the Union's own
-- systems, which ISO 3166-2 does not carry and which no concatenation of a
-- country and a region reaches. `fiscal_country || '-' || region` gets `US-CA`
-- and never gets `XI`, and a rule with one exception written into it collects
-- the second exception in silence.
--
-- `region` stays what it is: ISO 3166-2 **without** the prefix, for the
-- Canadian pack that will want to ask "which province" as a question with a
-- short list of answers. That is a different question from "which body of tax
-- law is this party under", and this migration answers the second one.
--
-- Four columns, all of them foreign keys into `territories`, which is what
-- makes them reviewable: a code nobody can look up is a string, and a string
-- is what `jurisdiction` has been since the day it was added.
--
--   `companies.territory_code`         where this company is established
--   `contacts.territory_code`          where this party is
--   `documents.supply_territory_code`  where the supply takes place
--   `taxes.applies_seller_territory`   where the seller has to be
--   `taxes.applies_buyer_territory`    where the buyer has to be
--   `taxes.applies_supply_territory`   where the supply has to be
--
-- All six are nullable, and null is the ordinary case. A Belgian company will
-- never set one; asking every installation in Europe to answer a question the
-- common system does not pose would be the country-default mistake with its
-- sign flipped.

alter table companies add column if not exists territory_code        text references territories(code);
alter table contacts  add column if not exists territory_code        text references territories(code);
alter table documents add column if not exists supply_territory_code text references territories(code);

-- A foreign key is read the way `currency_code` is: by the row that holds it,
-- and by the check that a territory is still referenced before it is taken
-- away. One index per key, leading with the key's own column.
create index if not exists companies_territory_idx on companies (territory_code);
create index if not exists contacts_territory_idx on contacts (territory_code);
create index if not exists documents_supply_territory_idx on documents (supply_territory_code);

comment on column companies.territory_code is
  'Territory of `territories` this company is established in for tax, where the country is not precise enough: US-CA for a Californian filer, XI for a Northern Irish one. Null everywhere the country is the answer, which is every country of the common system of VAT — the resolution then reads fiscal_country. Distinct from `region`, which is a province code without a prefix and answers a different question.';
comment on column contacts.territory_code is
  'Territory of `territories` this party is in, where its country is not precise enough. Null resolves to `country`.';
comment on column documents.supply_territory_code is
  'Territory of `territories` the supply takes place in, where `delivery_country` is not precise enough — a delivery to US-CA and one to US-NY are both US. Null resolves to delivery_country, and then to the buyer''s territory: a supply nobody said anything else about is delivered to the person who bought it.';

alter table tax_templates
  add column if not exists applies_seller_territory text references territories(code),
  add column if not exists applies_buyer_territory  text references territories(code),
  add column if not exists applies_supply_territory text references territories(code);

alter table taxes
  add column if not exists applies_seller_territory text references territories(code),
  add column if not exists applies_buyer_territory  text references territories(code),
  add column if not exists applies_supply_territory text references territories(code);

create index if not exists tax_templates_applies_seller_territory_idx on tax_templates (applies_seller_territory);
create index if not exists tax_templates_applies_buyer_territory_idx  on tax_templates (applies_buyer_territory);
create index if not exists tax_templates_applies_supply_territory_idx on tax_templates (applies_supply_territory);
create index if not exists taxes_applies_seller_territory_idx on taxes (applies_seller_territory);
create index if not exists taxes_applies_buyer_territory_idx  on taxes (applies_buyer_territory);
create index if not exists taxes_applies_supply_territory_idx on taxes (applies_supply_territory);

comment on column tax_templates.applies_seller_territory is
  'Territory the seller has to be in for this tax to apply, from `applies_when.seller_in` of the pack. Null means the tax says nothing about the seller.';
comment on column tax_templates.applies_buyer_territory is
  'Territory the buyer has to be in, from `applies_when.buyer_in`. Null means the tax says nothing about the buyer.';
comment on column tax_templates.applies_supply_territory is
  'Territory the supply has to take place in, from `applies_when.supply_in`. A sale is taxed where the goods are delivered, which is why this is not the same column as the buyer''s.';
comment on column taxes.applies_seller_territory is
  'Territory the seller has to be in for this tax to apply. post_document() refuses a document that contradicts it; it never chooses a tax for anybody.';
comment on column taxes.applies_buyer_territory is
  'Territory the buyer has to be in for this tax to apply.';
comment on column taxes.applies_supply_territory is
  'Territory the supply has to take place in for this tax to apply.';

-- ---------------------------------------------------------------------------
-- A condition is satisfied by the territory named and by everything inside it
--
-- `territories.parent_code` already draws the tree: `XI` hangs off `GB`,
-- `ES-CE` off `ES`, `US-CA` off `US`. So `seller_in: 'GB'` covers a seller in
-- Northern Ireland and `seller_in: 'XI'` does not cover a seller in Great
-- Britain, which is exactly what lets one country's pack carry two sets of
-- taxes and offer each where it applies.
--
-- The walk is bounded by the tree and the tree is two deep everywhere today;
-- the recursion is written all the same, because a table nobody can add a
-- third level to is a table somebody will add a third level to.
--
-- A code the table does not carry answers false rather than raising: the
-- foreign keys above mean the only way to get one here is a party column
-- resolving to a country that has no row, and a supply to a place the
-- reference data has never heard of does not satisfy a condition naming a
-- place it has.
-- ---------------------------------------------------------------------------

create or replace function territory_within(p_code text, p_of text)
returns boolean
language sql
stable
as $$
  with recursive up as (
    select t.code, t.parent_code
      from territories t
     where t.code = upper(btrim(p_code))
    union all
    select t.code, t.parent_code
      from territories t
      join up on up.parent_code = t.code
  )
  select exists (select 1 from up where up.code = upper(btrim(p_of)));
$$;

comment on function territory_within(text, text) is
  'True when the first territory is the second one or lies inside it, following territories.parent_code: US-CA is within US, XI is within GB, and neither is within the other. False for a code this table does not carry.';

-- ---------------------------------------------------------------------------
-- Where the three parties of a document are
--
-- `p_party` is a closed vocabulary of three values and raises on a fourth,
-- which is how every other vocabulary of this schema behaves.
--
--   `seller`  the company on a sale, the contact on a purchase. Decided by the
--             kind of document and never by the row: a purchase invoice is
--             somebody else's sale.
--   `buyer`   the other one.
--   `supply`  the place of supply: `supply_territory_code`, failing that
--             `delivery_country` — BG-15 of EN 16931, which `documents` has
--             carried since the day it existed and which is exactly the
--             statement that the place of delivery is not the billing address
--             — and failing that the buyer's territory.
--
-- The last rung is the one worth arguing about and the argument is that the
-- alternative is worse: a supply with no delivery address is not an unknown
-- place, it is the ordinary case of a seller and a buyer in one room. Refusing
-- it would refuse every invoice in Europe the day a pack there conditioned one
-- tax on a territory.
--
-- Null comes back where the ladder runs out — a contact with no country and no
-- territory, on a document with no delivery address. `post_document()` turns
-- that into a refusal that names the party, the tax and the column that would
-- answer, and only for a tax that actually asked.
-- ---------------------------------------------------------------------------

create or replace function document_territory(p_document_id uuid, p_party text)
returns text
language plpgsql
stable
as $$
declare
  v_doc      documents%rowtype;
  v_is_sale  boolean;
  v_company  text;
  v_contact  text;
  v_buyer    text;
begin
  if p_party not in ('seller', 'buyer', 'supply') then
    raise exception 'unknown_party: % is not seller, buyer or supply', p_party;
  end if;

  select * into v_doc from documents where id = p_document_id;
  if not found then
    raise exception 'unknown_document: document % does not exist', p_document_id;
  end if;

  v_is_sale := v_doc.doc_type in ('sale_invoice', 'sale_credit_note', 'sale_quote');

  select coalesce(c.territory_code, c.fiscal_country) into v_company
    from companies c where c.id = v_doc.company_id;
  select coalesce(k.territory_code, k.country) into v_contact
    from contacts k where k.id = v_doc.contact_id;

  v_buyer := case when v_is_sale then v_contact else v_company end;

  if p_party = 'seller' then
    return case when v_is_sale then v_company else v_contact end;
  elsif p_party = 'buyer' then
    return v_buyer;
  end if;

  return coalesce(v_doc.supply_territory_code, v_doc.delivery_country, v_buyer);
end;
$$;

comment on function document_territory(uuid, text) is
  'The territory of one party to a document: seller, buyer or supply. The seller is the company on a sale and the contact on a purchase, each resolving to its own territory_code and failing that to its country. The supply is the document''s supply_territory_code, failing that its delivery_country (BG-15), failing that the buyer''s territory. Null where none of those was ever recorded.';

revoke execute on function territory_within(text, text)    from public, anon;
revoke execute on function document_territory(uuid, text)  from public, anon;
grant  execute on function territory_within(text, text)    to authenticated, service_role;
grant  execute on function document_territory(uuid, text)  to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- The readers
--
-- Four functions are replaced, and three of them only to carry three columns
-- through a copy. `post_document()` is the one that gains a behaviour.
--
-- `install_country_template()` and `pack_upgrade()` copy a template into a
-- company, and a column missing on one side of a copy is the defect
-- `price_include` was for a whole release. `pack_upgrade_diff()` compares the
-- two, so that a pack which moves a tax from one territory to another shows up
-- as a difference a company is asked about rather than as a silent divergence.
-- ---------------------------------------------------------------------------

create or replace function install_country_template(
  p_company_id uuid,
  p_country    char(2),
  p_language   char(2) default null,
  p_chart_code text default null
)
returns void
language plpgsql
as $$
declare
  v_defaults country_defaults%rowtype;
  r          record;
  v_tax_id   uuid;
  v_language char(2);
  v_version  text;
  v_chart    text;
  v_charts   text;
begin
  if not exists (select 1 from companies where id = p_company_id) then
    raise exception 'unknown_company: %', p_company_id;
  end if;

  -- Which chart. The caller names one, or the pack's default stands. A named
  -- chart that does not exist is an error that lists what does: guessing here
  -- would install the wrong plan of accounts and nobody would notice for a
  -- year.
  if p_chart_code is null then
    select c.code into v_chart
      from chart_templates c
     where c.country = p_country and c.is_default;
    if v_chart is null then
      -- No pack for this country, or a pack that names no default chart.
      raise exception 'unknown_country_template: no chart of accounts seeded for %', p_country;
    end if;
  else
    select c.code into v_chart
      from chart_templates c
     where c.country = p_country and c.code = p_chart_code;
    if v_chart is null then
      select string_agg(c.code, ', ' order by c.code) into v_charts
        from chart_templates c where c.country = p_country;
      raise exception 'unknown_chart: % has no chart %. It has: %',
        p_country, p_chart_code, coalesce(v_charts, 'none');
    end if;
  end if;

  if not exists (
    select 1 from account_templates
     where country = p_country and chart_code = v_chart
  ) then
    raise exception 'unknown_country_template: chart % of % holds no account', v_chart, p_country;
  end if;

  -- The language of the copy: what the caller asked for, else what the
  -- company keeps its books in.
  select coalesce(p_language, c.language) into v_language
    from companies c where c.id = p_company_id;

  -- 1. Accounts, without the hierarchy.
  insert into accounts (company_id, code, name, name_i18n, statement_hint,
                        account_type, reconcilable)
  select p_company_id, t.code,
         label_for(t.name, t.name_i18n, array[v_language]),
         t.name_i18n, t.statement_hint, t.account_type, t.reconcilable
    from account_templates t
   where t.country = p_country
     and t.chart_code = v_chart
  on conflict (company_id, code) do nothing;

  -- 2. Hierarchy, now that every code exists.
  update accounts a
     set parent_id = p.id
    from account_templates t
    join accounts p on p.company_id = p_company_id and p.code = t.parent_code
   where a.company_id = p_company_id
     and a.code = t.code
     and t.country = p_country
     and t.chart_code = v_chart
     and t.parent_code is not null
     and a.parent_id is null;

  -- 3. Journals. Common to every chart of the country.
  insert into journals (company_id, code, name, name_i18n, journal_type)
  select p_company_id, t.code,
         label_for(t.name, t.name_i18n, array[v_language]),
         t.name_i18n, t.journal_type
    from journal_templates t
   where t.country = p_country
  on conflict (company_id, code) do nothing;

  -- 4. Taxes and their postings. Also common: a chart changes how a company
  --    presents itself, not what it owes.
  for r in
    select * from tax_templates where country = p_country order by sequence, code
  loop
    v_tax_id := null;
    insert into taxes (company_id, code, name, name_i18n, description, amount_type, amount,
                       applies_to, treatment, country, valid_from, valid_to,
                       legal_reference, vat_category, exemption_code, sequence,
                       tax_kind, recoverable, jurisdiction, price_include,
                       cash_basis, cash_basis_transition_account_id,
                       applies_seller_territory, applies_buyer_territory,
                       applies_supply_territory)
    values (p_company_id, r.code,
            label_for(r.name, r.name_i18n, array[v_language]),
            r.name_i18n, r.description, r.amount_type, r.amount,
            r.applies_to, r.treatment, p_country, r.valid_from, r.valid_to,
            r.legal_reference, r.vat_category, r.exemption_code, r.sequence,
            r.tax_kind, r.recoverable, r.jurisdiction, r.price_include,
            r.cash_basis, account_id_by_code(p_company_id, r.cash_basis_transition_account_code),
            r.applies_seller_territory, r.applies_buyer_territory,
            r.applies_supply_territory)
    on conflict (company_id, code) do nothing
    returning id into v_tax_id;

    if v_tax_id is null then
      continue;
    end if;

    insert into tax_postings (tax_id, company_id, document_kind, posting_type,
                              factor_percent, account_id, declaration_box,
                              declaration_boxes, box_factor_percent, report_code,
                              sequence)
    select v_tax_id, p_company_id, tp.document_kind, tp.posting_type,
           tp.factor_percent, account_id_by_code(p_company_id, tp.account_code),
           tp.declaration_box, tp.declaration_boxes, tp.box_factor_percent,
           tp.report_code, tp.sequence
      from tax_posting_templates tp
     where tp.tax_template_id = r.id
     order by tp.sequence;
  end loop;

  -- 5. Roles.
  select * into v_defaults from country_defaults where country = p_country;
  if found then
    update companies c
       set receivable_account_id       = coalesce(c.receivable_account_id, account_id_by_code(p_company_id, v_defaults.receivable_code)),
           payable_account_id          = coalesce(c.payable_account_id, account_id_by_code(p_company_id, v_defaults.payable_code)),
           suspense_account_id         = coalesce(c.suspense_account_id, account_id_by_code(p_company_id, v_defaults.suspense_code)),
           rounding_account_id         = coalesce(c.rounding_account_id, account_id_by_code(p_company_id, v_defaults.rounding_code)),
           retained_earnings_account_id = coalesce(c.retained_earnings_account_id, account_id_by_code(p_company_id, v_defaults.retained_earnings_code)),
           default_sales_account_id    = coalesce(c.default_sales_account_id, account_id_by_code(p_company_id, v_defaults.sales_account_code)),
           default_purchase_account_id = coalesce(c.default_purchase_account_id, account_id_by_code(p_company_id, v_defaults.purchase_account_code)),
           sales_journal_id            = coalesce(c.sales_journal_id, (select id from journals where company_id = p_company_id and code = v_defaults.sales_journal_code)),
           purchase_journal_id         = coalesce(c.purchase_journal_id, (select id from journals where company_id = p_company_id and code = v_defaults.purchase_journal_code)),
           miscellaneous_journal_id    = coalesce(c.miscellaneous_journal_id, (select id from journals where company_id = p_company_id and code = v_defaults.misc_journal_code))
     where c.id = p_company_id;

    -- 6. The financial journals point at their account.
    update journals j
       set default_account_id = account_id_by_code(p_company_id, v_defaults.bank_account_code)
     where j.company_id = p_company_id
       and j.journal_type = 'bank'
       and j.default_account_id is null
       and v_defaults.bank_account_code is not null;

    update journals j
       set default_account_id = account_id_by_code(p_company_id, v_defaults.cash_account_code)
     where j.company_id = p_company_id
       and j.journal_type = 'cash'
       and j.default_account_id is null
       and v_defaults.cash_account_code is not null;
  end if;

  -- 7. What was copied, from which version, and on which chart.
  v_version := coalesce((select version from country_packs where country = p_country), '1.0.0');

  insert into company_packs (company_id, country, version, chart_code)
  values (p_company_id, p_country, v_version, v_chart)
  on conflict (company_id, country) do update
     set version = excluded.version,
         chart_code = excluded.chart_code,
         upgraded_at = now()
   where company_packs.version is distinct from excluded.version
      or company_packs.chart_code is distinct from excluded.chart_code;

  -- 8. The working chart. Everything wired above is pinned, so a company opens
  --    on the accounts its country model actually points at rather than on the
  --    whole transcription.
  perform pin_referenced_accounts(p_company_id);
end;
$$;


create or replace function pack_upgrade_diff(
  p_company_id uuid,
  p_country    char(2) default null
)
returns table (
  object text,
  key    text,
  change text,
  rule   pack_change_rule,
  detail jsonb
)
language plpgsql
stable
as $$
declare
  v_country char(2);
  v_chart   text;
begin
  select coalesce(p_country, c.country) into v_country
    from companies c where c.id = p_company_id;
  if v_country is null then
    raise exception 'unknown_company: %', p_company_id;
  end if;

  select cp.chart_code into v_chart
    from company_packs cp
   where cp.company_id = p_company_id and cp.country = v_country;
  if v_chart is null then
    raise exception 'no_pack_installed: company % holds no % pack, so there is nothing to upgrade from', p_company_id, v_country;
  end if;

  -- Accounts -----------------------------------------------------------------
  return query
  select 'account', t.code, 'missing', 'addition'::pack_change_rule,
         jsonb_build_object('pack', jsonb_build_object('name', t.name, 'account_type', t.account_type))
    from account_templates t
   where t.country = v_country and t.chart_code = v_chart
     and not exists (select 1 from accounts a where a.company_id = p_company_id and a.code = t.code);

  return query
  select 'account', a.code, 'differs', 'review'::pack_change_rule,
         jsonb_build_object(
           'pack', jsonb_build_object('name', t.name, 'account_type', t.account_type),
           'company', jsonb_build_object('name', a.name, 'account_type', a.account_type))
    from accounts a
    join account_templates t
      on t.country = v_country and t.chart_code = v_chart and t.code = a.code
   where a.company_id = p_company_id
     and (label_for(t.name, t.name_i18n, preferred_languages(p_company_id)) is distinct from a.name
          or t.account_type is distinct from a.account_type);

  return query
  select 'account', a.code, 'company_only', 'review'::pack_change_rule,
         jsonb_build_object('company', jsonb_build_object('name', a.name, 'account_type', a.account_type))
    from accounts a
   where a.company_id = p_company_id
     and not exists (select 1 from account_templates t
                      where t.country = v_country and t.chart_code = v_chart and t.code = a.code);

  -- Journals -----------------------------------------------------------------
  return query
  select 'journal', t.code, 'missing', 'addition'::pack_change_rule,
         jsonb_build_object('pack', jsonb_build_object('name', t.name, 'journal_type', t.journal_type))
    from journal_templates t
   where t.country = v_country
     and not exists (select 1 from journals j where j.company_id = p_company_id and j.code = t.code);

  return query
  select 'journal', j.code, 'differs', 'review'::pack_change_rule,
         jsonb_build_object(
           'pack', jsonb_build_object('name', t.name, 'journal_type', t.journal_type),
           'company', jsonb_build_object('name', j.name, 'journal_type', j.journal_type))
    from journals j
    join journal_templates t on t.country = v_country and t.code = j.code
   where j.company_id = p_company_id
     and (t.name is distinct from j.name or t.journal_type is distinct from j.journal_type);

  -- Taxes --------------------------------------------------------------------
  return query
  select 'tax', t.code, 'missing', 'addition'::pack_change_rule,
         jsonb_build_object('pack', jsonb_build_object(
           'name', t.name, 'amount', t.amount, 'amount_type', t.amount_type,
           'valid_from', t.valid_from, 'valid_to', t.valid_to))
    from tax_templates t
   where t.country = v_country
     and not exists (select 1 from taxes x where x.company_id = p_company_id and x.code = t.code);

  -- A validity the pack has closed and the company still holds open, or holds
  -- open longer. This is a rate change arriving: the old tax stops on the day
  -- the pack says, and the new rate is an addition above.
  return query
  select 'tax', x.code, 'valid_to', 'closure'::pack_change_rule,
         jsonb_build_object('pack', jsonb_build_object('valid_to', t.valid_to),
                            'company', jsonb_build_object('valid_to', x.valid_to))
    from taxes x
    join tax_templates t on t.country = v_country and t.code = x.code
   where x.company_id = p_company_id
     and t.valid_to is not null
     and (x.valid_to is null or x.valid_to > t.valid_to);

  return query
  select 'tax', x.code, 'differs', 'review'::pack_change_rule,
         jsonb_build_object(
           'pack', jsonb_build_object('name', t.name, 'amount', t.amount,
                                      'amount_type', t.amount_type, 'treatment', t.treatment,
                                      'applies_to', t.applies_to, 'tax_kind', t.tax_kind,
                                      'recoverable', t.recoverable, 'valid_from', t.valid_from,
                                      'applies_seller_territory', t.applies_seller_territory,
                                      'applies_buyer_territory', t.applies_buyer_territory,
                                      'applies_supply_territory', t.applies_supply_territory),
           'company', jsonb_build_object('name', x.name, 'amount', x.amount,
                                         'amount_type', x.amount_type, 'treatment', x.treatment,
                                         'applies_to', x.applies_to, 'tax_kind', x.tax_kind,
                                         'recoverable', x.recoverable, 'valid_from', x.valid_from,
                                         'applies_seller_territory', x.applies_seller_territory,
                                         'applies_buyer_territory', x.applies_buyer_territory,
                                         'applies_supply_territory', x.applies_supply_territory))
    from taxes x
    join tax_templates t on t.country = v_country and t.code = x.code
   where x.company_id = p_company_id
     and (label_for(t.name, null, preferred_languages(p_company_id)) is distinct from x.name
          or t.amount is distinct from x.amount
          or t.amount_type is distinct from x.amount_type
          or t.treatment is distinct from x.treatment
          or t.applies_to is distinct from x.applies_to
          or t.tax_kind is distinct from x.tax_kind
          or t.recoverable is distinct from x.recoverable
          or t.valid_from is distinct from x.valid_from
          -- Where a tax applies is a fact about the tax, and a pack that moves
          -- it is a pack the company has to be shown.
          or t.applies_seller_territory is distinct from x.applies_seller_territory
          or t.applies_buyer_territory  is distinct from x.applies_buyer_territory
          or t.applies_supply_territory is distinct from x.applies_supply_territory);

  return query
  select 'tax', x.code, 'company_only', 'review'::pack_change_rule,
         jsonb_build_object('company', jsonb_build_object('name', x.name, 'amount', x.amount))
    from taxes x
   where x.company_id = p_company_id
     and x.country = v_country
     and not exists (select 1 from tax_templates t where t.country = v_country and t.code = x.code);

  -- What a tax books. Compared as a whole per tax rather than line by line: a
  -- posting has no identity of its own, and "this tax now books its
  -- non-deductible share somewhere else" is one fact, not four.
  return query
  with pack as (
    select t.code,
           jsonb_agg(jsonb_build_object('document_kind', tp.document_kind,
                                        'posting_type', tp.posting_type,
                                        'factor_percent', tp.factor_percent,
                                        'account_code', tp.account_code,
                                        'declaration_box', tp.declaration_box,
                                        'declaration_boxes', to_jsonb(tp.declaration_boxes),
                                        'box_factor_percent', tp.box_factor_percent,
                                        'report_code', tp.report_code)
                     order by tp.document_kind, tp.posting_type, tp.sequence) as postings
      from tax_templates t
      join tax_posting_templates tp on tp.tax_template_id = t.id
     where t.country = v_country
     group by t.code
  ), held as (
    select x.code,
           jsonb_agg(jsonb_build_object('document_kind', p.document_kind,
                                        'posting_type', p.posting_type,
                                        'factor_percent', p.factor_percent,
                                        'account_code', a.code,
                                        'declaration_box', p.declaration_box,
                                        'declaration_boxes', to_jsonb(p.declaration_boxes),
                                        'box_factor_percent', p.box_factor_percent,
                                        'report_code', p.report_code)
                     order by p.document_kind, p.posting_type, p.sequence) as postings
      from taxes x
      join tax_postings p on p.tax_id = x.id
      left join accounts a on a.id = p.account_id
     where x.company_id = p_company_id
     group by x.code
  )
  select 'tax_posting', pack.code, 'differs', 'review'::pack_change_rule,
         jsonb_build_object('pack', pack.postings, 'company', held.postings)
    from pack
    join held on held.code = pack.code
   where pack.postings is distinct from held.postings;
end;
$$;


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

  if auth.uid() is not null and not has_capability(p_company_id, 'company.write') then
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
                         applies_supply_territory)
      values (p_company_id, v_template.code, v_template.name, v_template.description,
              v_template.amount_type, v_template.amount, v_template.applies_to,
              v_template.treatment, v_country, v_template.valid_from, v_template.valid_to,
              v_template.legal_reference, v_template.vat_category, v_template.exemption_code,
              v_template.sequence, v_template.tax_kind, v_template.recoverable,
              v_template.jurisdiction, v_template.price_include, v_template.cash_basis,
              account_id_by_code(p_company_id, v_template.cash_basis_transition_account_code),
              v_template.applies_seller_territory, v_template.applies_buyer_territory,
              v_template.applies_supply_territory)
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
             applies_supply_territory = t.applies_supply_territory
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


-- ---------------------------------------------------------------------------
-- post_document, which refuses a tax the document contradicts
-- ---------------------------------------------------------------------------

create or replace function post_document(p_document_id uuid)
returns entries
language plpgsql
as $$
declare
  v_doc        documents%rowtype;
  v_entry      entries%rowtype;
  v_journal    uuid;
  v_date       date;
  v_is_sale    boolean;
  v_is_credit  boolean;
  v_kind       tax_document_kind;
  v_base_credit boolean;
  v_seq        integer := 0;
  v_contact    uuid;
  v_maturity   date;
  v_terms      smallint;
  v_counterpart uuid;
  -- Plain `numeric`, not `numeric(16, 2)`: a local that carries a scale is a
  -- second rounding rule hiding in a declaration, and it is not the currency's.
  -- The only thing that rounds here is `round_amount`.
  v_diff       numeric;
  v_diff_cur   numeric;
  v_amount     numeric;
  v_book       numeric;
  v_box_amount numeric;
  v_share      numeric;
  v_share_book numeric;
  v_share_box  numeric;
  v_left       numeric;
  v_left_box   numeric;
  v_side_left     numeric;
  v_side_left_neg numeric;
  v_side_credit boolean;
  v_label      text;
  v_rate       numeric(18, 8);
  v_home       char(3);
  v_foreign    boolean;
  v_total_cur  numeric;
  -- Two currencies, one method: the document is stated in its own and the
  -- ledger keeps the company's, and a yen invoice paid in euros rounds each
  -- side at the decimals that side has.
  v_round      money_rounding;
  v_book_round money_rounding;
  v_cash       boolean;
  v_transition uuid;
  v_postings   integer;
  -- Where the three parties of this document are, resolved once and only when
  -- a tax on it asks. `document_territory()` is the ladder.
  v_terr_seller text;
  v_terr_buyer  text;
  v_terr_supply text;
  r            record;
  p            record;
  g            record;
begin
  select * into v_doc from documents where id = p_document_id for update;
  if not found then
    raise exception 'unknown_document: document % does not exist', p_document_id;
  end if;
  if v_doc.state = 'posted' then
    raise exception 'document_already_posted: document % is already posted', p_document_id;
  end if;
  if v_doc.state = 'cancelled' then
    raise exception 'document_cancelled: document % cannot be posted', p_document_id;
  end if;
  if v_doc.entry_id is not null then
    raise exception 'document_already_booked: document % already points at entry %',
      p_document_id, v_doc.entry_id;
  end if;

  if v_doc.doc_type in ('sale_quote', 'purchase_order') then
    raise exception 'document_not_accountable: a % is not booked', v_doc.doc_type;
  end if;

  v_is_sale   := v_doc.doc_type in ('sale_invoice', 'sale_credit_note');
  v_is_credit := v_doc.doc_type in ('sale_credit_note', 'purchase_credit_note');
  v_kind      := case when v_is_credit then 'credit_note' else 'invoice' end::tax_document_kind;
  -- Sale invoice and purchase credit note credit the base; the other two debit it.
  v_base_credit := (v_is_sale <> v_is_credit);

  v_date := coalesce(v_doc.accounting_date, v_doc.document_date);

  if not exists (
    select 1 from document_lines
     where document_id = p_document_id and line_type = 'product' and amount_untaxed <> 0
  ) then
    raise exception 'document_empty: document % has no billable line', p_document_id;
  end if;

  -- A fixed-amount tax has no basis to spread over lines; refuse rather than
  -- guess.
  if exists (
    select 1 from document_lines l join taxes t on t.id = l.tax_id
     where l.document_id = p_document_id and t.amount_type <> 'percent'
  ) then
    raise exception 'unsupported_tax_amount_type: only percentage taxes can be posted';
  end if;

  -- Every tax used must be in force on the accounting date.
  for r in
    select distinct t.id, t.code, t.valid_from, t.valid_to
      from document_lines l join taxes t on t.id = l.tax_id
     where l.document_id = p_document_id
  loop
    if v_date < r.valid_from or (r.valid_to is not null and v_date > r.valid_to) then
      raise exception 'tax_not_in_force: tax % is not applicable on %', r.code, v_date;
    end if;
  end loop;

  -- Every tax that names a territory must find the parties where it says they
  -- are. This is the one thing the core may do with a territory condition: it
  -- refuses a tax that cannot apply, and it never chooses, substitutes or
  -- suggests one — the core picks no tax for anybody, in any country.
  --
  -- The resolution is skipped entirely where nothing asks, which is every
  -- document of every pack written before this migration.
  if exists (
    select 1
      from document_lines l
      join taxes t on t.id = l.tax_id
     where l.document_id = p_document_id
       and (t.applies_seller_territory is not null
         or t.applies_buyer_territory  is not null
         or t.applies_supply_territory is not null)
  ) then
    v_terr_seller := document_territory(p_document_id, 'seller');
    v_terr_buyer  := document_territory(p_document_id, 'buyer');
    v_terr_supply := document_territory(p_document_id, 'supply');

    for r in
      select distinct t.code,
             t.applies_seller_territory as seller,
             t.applies_buyer_territory  as buyer,
             t.applies_supply_territory as supply
        from document_lines l
        join taxes t on t.id = l.tax_id
       where l.document_id = p_document_id
         and (t.applies_seller_territory is not null
           or t.applies_buyer_territory  is not null
           or t.applies_supply_territory is not null)
       order by 1
    loop
      for p in
        select v.party, v.wanted, v.actual, v.hint
          from (values
            ('seller', r.seller, v_terr_seller,
             'territory_code on the party that sells, or the country beside it'),
            ('buyer',  r.buyer,  v_terr_buyer,
             'territory_code on the party that buys, or the country beside it'),
            ('supply', r.supply, v_terr_supply,
             'supply_territory_code or delivery_country on the document')
          ) as v (party, wanted, actual, hint)
         where v.wanted is not null
         order by v.party
      loop
        if p.actual is null then
          raise exception 'no_party_territory: tax % applies where the % is in %, and nothing on this document says where the % is; set %',
            r.code, p.party, p.wanted, p.party, p.hint;
        end if;
        if not territory_within(p.actual, p.wanted) then
          raise exception 'tax_territory_mismatch: tax % applies where the % is in %; on this document the % is in %',
            r.code, p.party, p.wanted, p.party, p.actual;
        end if;
      end loop;
    end loop;
  end if;

  -- Totals are derived; make sure they reflect the lines as they stand now.
  perform documents_refresh_totals(p_document_id);
  select * into v_doc from documents where id = p_document_id;

  select c.currency_code into v_home from companies c where c.id = v_doc.company_id;
  v_rate    := v_doc.exchange_rate;
  v_foreign := v_doc.currency_code <> v_home;
  v_round      := rounding_of(v_doc.company_id, v_doc.currency_code);
  v_book_round := rounding_of(v_doc.company_id);

  v_journal := coalesce(
    v_doc.journal_id,
    case when v_is_sale
      then (select sales_journal_id from companies where id = v_doc.company_id)
      else (select purchase_journal_id from companies where id = v_doc.company_id)
    end
  );
  if v_journal is null then
    raise exception 'no_journal: set journal_id on the document or a default journal on the company';
  end if;

  perform assert_period_open(v_doc.company_id, v_date, true);

  v_label := coalesce(v_doc.number, v_doc.supplier_reference, 'document');

  insert into entries (company_id, journal_id, fiscal_year_id, entry_date, reference,
                       description, state, document_id, currency_code)
  values (v_doc.company_id, v_journal, fiscal_year_at(v_doc.company_id, v_date), v_date,
          coalesce(v_doc.number, v_doc.supplier_reference),
          v_label || case when v_doc.supplier_reference is not null and v_doc.number is not null
                          then ' / ' || v_doc.supplier_reference else '' end,
          'draft', p_document_id, v_doc.currency_code)
  returning * into v_entry;

  -- ------------------------------------------------------------------ bases
  for r in
    select l.account_id,
           l.tax_id,
           sum(l.amount_untaxed) as base_amount,
           min(l.sequence)       as seq,
           string_agg(distinct l.name, ', ') as label
      from document_lines l
     where l.document_id = p_document_id
       and l.line_type = 'product'
     group by l.account_id, l.tax_id
    having sum(l.amount_untaxed) <> 0
     order by 4
  loop
    select tp.posting_type, tp.declaration_box, tp.factor_percent, tp.box_factor_percent,
           coalesce(t.cash_basis, false) as cash_basis
      into p
      from tax_postings tp
      join taxes t on t.id = tp.tax_id
     where tp.tax_id = r.tax_id
       and tp.document_kind = v_kind
       and tp.posting_type = 'base'
     limit 1;

    v_amount := round_amount(r.base_amount * coalesce(p.factor_percent, 100) / 100, v_round);
    v_book   := round_amount(v_amount / v_rate, v_book_round);
    v_seq := v_seq + 10;

    insert into entry_lines (entry_id, company_id, account_id, sequence, name,
                             debit, credit, tax_id, tax_line, posting_type,
                             declaration_box, box_amount, currency_code, amount_currency)
    values (v_entry.id, v_doc.company_id, r.account_id, v_seq, left(r.label, 200),
            case when v_base_credit then 0 else v_book end,
            case when v_base_credit then v_book else 0 end,
            r.tax_id, false, p.posting_type,
            case when coalesce(p.cash_basis, false) then null else p.declaration_box end,
            case when p.declaration_box is null then null
                 else round_amount(r.base_amount * coalesce(p.box_factor_percent, 100) / 100 / v_rate,
                                   v_book_round) end,
            v_doc.currency_code,
            case when v_foreign then v_amount end);
  end loop;

  -- ------------------------------------------------------------------ taxes
  for r in
    select s.tax_id, s.tax_code, s.tax_name, s.tax_amount
      from document_tax_summary s
     where s.document_id = p_document_id
       and s.tax_id is not null
       and s.tax_amount <> 0
     order by s.tax_code
  loop
    select t.cash_basis, t.cash_basis_transition_account_id
      into v_cash, v_transition
      from taxes t where t.id = r.tax_id;

    if v_cash then
      -- A tax that waits needs somewhere to wait. Refuse by name rather than
      -- book it on the account it is due on, which would make it due.
      if v_transition is null then
        raise exception 'no_cash_basis_account: tax % falls due on collection and names no transition account',
          r.tax_code;
      end if;
      -- One posting per side, or the transition lines of a document cannot be
      -- told apart when the matching sends each of them on. A tax whose
      -- postings net out has nothing waiting to collect anyway.
      select count(*) into v_postings
        from tax_postings tp
       where tp.tax_id = r.tax_id and tp.document_kind = v_kind
         and tp.posting_type = 'tax';
      if v_postings > 1 then
        raise exception 'cash_basis_split_tax: tax % falls due on collection and has % tax postings; it takes one',
          r.tax_code, v_postings;
      end if;
      if exists (select 1 from tax_postings tp
                  where tp.tax_id = r.tax_id and tp.document_kind = v_kind
                    and tp.posting_type = 'tax_on_base') then
        raise exception 'cash_basis_tax_on_base: tax % falls due on collection and carries a non-deductible share; a cost is not deferred',
          r.tax_code;
      end if;
      -- And it needs a box to fall due *into*. `settle_cash_basis_tax()` only
      -- ever looks at lines that carry a `box_amount`, and a posting with no
      -- `declaration_box` produces none — so the amount would sit on the
      -- transition account for ever, settled by nothing and reported by
      -- nothing, with no error anywhere. Refuse it here, where the pack can
      -- still be corrected, rather than discover it in a balance years later.
      if not exists (select 1 from tax_postings tp
                      where tp.tax_id = r.tax_id and tp.document_kind = v_kind
                        and tp.posting_type = 'tax'
                        and tp.declaration_box is not null) then
        raise exception 'no_cash_basis_box: tax % falls due on collection and its posting names no declaration box; the amount would wait on the transition account and never settle',
          r.tax_code;
      end if;
    end if;

    -- The postings of one side share out the tax of the group; the last of
    -- each side takes what is left. Until `tax_on_base` there was never more
    -- than one posting per side, so this changes no existing tax by a cent —
    -- and it is what keeps a 50/50 split honest: 0.63 becomes 0.32 and 0.31,
    -- where rounding each half on its own would book 0.64 against a document
    -- that totals 0.63.
    v_side_left     := null;
    v_side_left_neg := null;

    for p in
      select tp.posting_type, tp.factor_percent, tp.account_id,
             tp.declaration_box, tp.box_factor_percent,
             case when tp.factor_percent >= 0 then 1 else -1 end as side,
             sum(abs(tp.factor_percent))
               over (partition by case when tp.factor_percent >= 0 then 1 else -1 end)
               as side_factor,
             row_number() over (
               partition by case when tp.factor_percent >= 0 then 1 else -1 end
               order by tp.sequence, tp.id)
             = count(*) over (
               partition by case when tp.factor_percent >= 0 then 1 else -1 end)
               as is_last_of_side
        from tax_postings tp
       where tp.tax_id = r.tax_id
         and tp.document_kind = v_kind
         and tp.posting_type in ('tax', 'tax_on_base')
       order by tp.sequence, tp.id
    loop
      -- The tax of the group was rounded once, in the view. Every posting is
      -- a share of that one figure, never of a re-derived one.
      if p.side >= 0 then
        if v_side_left is null then
          v_side_left := round_amount(r.tax_amount * p.side_factor / 100, v_round);
        end if;
        if p.is_last_of_side then
          v_amount := v_side_left;
        else
          v_amount    := round_amount(r.tax_amount * abs(p.factor_percent) / 100, v_round);
          v_side_left := v_side_left - v_amount;
        end if;
      else
        if v_side_left_neg is null then
          v_side_left_neg := round_amount(r.tax_amount * p.side_factor / 100, v_round);
        end if;
        if p.is_last_of_side then
          v_amount := v_side_left_neg;
        else
          v_amount        := round_amount(r.tax_amount * abs(p.factor_percent) / 100, v_round);
          v_side_left_neg := v_side_left_neg - v_amount;
        end if;
      end if;

      if v_amount = 0 then
        continue;
      end if;
      -- A positive factor keeps the side of the base, a negative one flips it.
      v_side_credit := case when p.factor_percent >= 0 then v_base_credit else not v_base_credit end;
      -- The box keeps its own rounding: `box_factor_percent` was always
      -- independent from `factor_percent`, because a declaration figure is
      -- not a ledger figure and only the ledger has to balance.
      v_box_amount := case when p.declaration_box is null then null
                           else round_amount(r.tax_amount * p.box_factor_percent / 100 / v_rate,
                                             v_book_round) end;
      v_book := round_amount(v_amount / v_rate, v_book_round);

      if p.posting_type = 'tax' then
        v_seq := v_seq + 10;

        insert into entry_lines (entry_id, company_id, account_id, sequence, name,
                                 debit, credit, tax_id, tax_line, posting_type,
                                 declaration_box, box_amount, currency_code, amount_currency)
        values (v_entry.id, v_doc.company_id,
                case when v_cash then v_transition else p.account_id end,
                v_seq, r.tax_name,
                case when v_side_credit then 0 else v_book end,
                case when v_side_credit then v_book else 0 end,
                r.tax_id, true, p.posting_type,
                case when v_cash then null else p.declaration_box end,
                v_box_amount, v_doc.currency_code,
                case when v_foreign then v_amount end);
        continue;
      end if;

      -- `tax_on_base`: the tax is a cost, so it lands on the accounts of the
      -- lines it taxes, split in proportion to their base. The last share
      -- takes whatever is left, so the shares add up to the amount that was
      -- rounded once on the group and the entry still balances to the cent.
      v_left     := v_amount;
      v_left_box := v_box_amount;

      for g in
        select account_id,
               base_amount,
               seq,
               sum(base_amount) over ()                                   as total_base,
               row_number() over (order by seq) = count(*) over ()         as is_last
          from (
            select l.account_id,
                   sum(l.amount_untaxed) as base_amount,
                   min(l.sequence)       as seq
              from document_lines l
             where l.document_id = p_document_id
               and l.line_type = 'product'
               and l.tax_id = r.tax_id
             group by l.account_id
            having sum(l.amount_untaxed) <> 0
          ) as groups
         order by seq
      loop
        if g.is_last then
          v_share     := v_left;
          v_share_box := v_left_box;
        else
          v_share     := round_amount(v_amount * g.base_amount / g.total_base, v_round);
          v_share_box := case when v_box_amount is null then null
                              else round_amount(v_box_amount * g.base_amount / g.total_base,
                                                v_book_round) end;
          v_left      := v_left - v_share;
          v_left_box  := v_left_box - v_share_box;
        end if;

        if v_share = 0 then
          continue;
        end if;

        v_seq := v_seq + 10;
        v_share_book := round_amount(v_share / v_rate, v_book_round);

        -- `tax_line` stays false: the amount is on a base account and belongs
        -- to the base side of the declaration, which is why the Belgian grids
        -- 82 and 83 report it together with the base.
        insert into entry_lines (entry_id, company_id, account_id, sequence, name,
                                 debit, credit, tax_id, tax_line, posting_type,
                                 declaration_box, box_amount, currency_code, amount_currency)
        values (v_entry.id, v_doc.company_id, g.account_id, v_seq, r.tax_name,
                case when v_side_credit then 0 else v_share_book end,
                case when v_side_credit then v_share_book else 0 end,
                r.tax_id, false, p.posting_type,
                p.declaration_box, v_share_box, v_doc.currency_code,
                case when v_foreign then v_share end);
      end loop;
    end loop;
  end loop;

  -- ------------------------------------------------------------ counterpart
  select total_debit - total_credit into v_diff from entries where id = v_entry.id;
  select coalesce(sum(case when l.debit > 0 then l.amount_currency else -l.amount_currency end), 0)
    into v_diff_cur
    from entry_lines l where l.entry_id = v_entry.id;

  if v_diff = 0 then
    raise exception 'document_counterpart_zero: document % produced a nil counterpart', p_document_id;
  end if;

  v_contact := commercial_entity(v_doc.contact_id);
  v_counterpart := resolve_counterpart_account(v_doc.company_id, v_contact, v_is_sale);

  select payment_terms_days into v_terms from contacts where id = v_contact;
  v_maturity := coalesce(v_doc.due_date, v_doc.document_date + coalesce(v_terms, 30));

  v_amount := abs(v_diff);
  -- The counterpart balances the entry in both currencies. The total it is
  -- checked against is the document's own, which is the currency
  -- `amount_total` is stated in.
  v_total_cur := case when v_foreign then abs(v_diff_cur) else v_amount end;
  v_seq := v_seq + 10;

  insert into entry_lines (entry_id, company_id, account_id, sequence, name,
                           debit, credit, contact_id, date_maturity, currency_code,
                           amount_currency)
  values (v_entry.id, v_doc.company_id, v_counterpart, v_seq, v_label,
          case when v_diff > 0 then 0 else v_amount end,
          case when v_diff > 0 then v_amount else 0 end,
          v_contact, v_maturity, v_doc.currency_code,
          case when v_foreign then v_total_cur end);

  -- The ledger is right by construction. If the header disagrees, the header
  -- is what is wrong, and we say so instead of quietly patching a line.
  -- Half a unit of the document's own currency, which is what `0.005` used to
  -- mean when every currency was assumed to have cents.
  if abs(v_total_cur - abs(v_doc.amount_total)) > currency_unit(v_round) / 2 then
    raise exception 'document_total_mismatch: document % totals % but its lines book %',
      p_document_id, v_doc.amount_total, v_total_cur;
  end if;

  -- --------------------------------------------------------------- posting
  v_entry := post_entry(v_entry.id);

  update documents
     set state  = 'posted',
         number = coalesce(number, v_entry.number),
         entry_id = v_entry.id,
         accounting_date = v_date
   where id = p_document_id;

  return v_entry;
end;
$$;

comment on function post_document(uuid) is
  'Books a document: one entry, the bases on the accounts of the lines, the tax of each group rounded once and shared over the postings of the tax, each ledger line naming the posting type that wrote it. Refuses a tax whose applies_*_territory the document contradicts, by name, before anything reaches the ledger — and chooses no tax for anybody.';

-- No new table, so no new policy: the six columns sit on tables whose row
-- level security already decides who may read them, and `territories` keeps
-- the select policy it was created with. The two new functions are granted
-- above, beside their revokes.
