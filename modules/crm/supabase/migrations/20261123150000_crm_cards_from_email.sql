-- Ekwo — the `crm` module: cards build themselves from e-mail.
--
-- Until now a card was written by hand, or by an agent that first looked the
-- contact up, created it when it was missing, and guessed its organisation.
-- An e-mail already says who it is with: an address, and in that address a
-- domain the people of one organisation share. This migration lets the module
-- read it once, in the database, for every surface:
--
-- 1. **`crm.generic_email_domains`** — the domains that never name an
--    organisation: personal mailboxes, tools that send on somebody's behalf,
--    providers that host many unrelated organisations. Data, not code: the
--    module ships a list (`shipped`), an installation adds its own rows, and a
--    company may add rows of its own. A domain, or any sub-domain of it, on
--    the list is generic.
-- 2. **`crm.contact_from_email()`** — finds the contact an address belongs to,
--    or creates it, then finds its organisation by the domain, or creates it.
--    It never creates a second contact for an address already on file, and
--    never an organisation for a generic domain. Two contacts that still turn
--    out to be one party are joined by the socle's `merge_contacts()`, which
--    stays the only way two rows become one.
-- 3. **`crm.log_activity_by_email()`** — an activity named by an address
--    rather than by a contact id: the contact is resolved as above, then the
--    activity is written by `crm.log_activity()`, whose `(source, source_ref)`
--    makes a replay write nothing.
-- 4. **`crm.interactions_of()`** — the first and the last interaction of a
--    card, computed from its activities whenever they are read, never typed
--    in. `crm.card_of()` gives them on the card.
--
-- **No country, no language.** The list of generic domains is reference data
-- of the installation, whatever country its domains are registered in; an
-- organisation created from a domain is named by the domain, which the user
-- renames when they know better.

-- ---------------------------------------------------------------------------
-- 1. The domains that never name an organisation
-- ---------------------------------------------------------------------------

create table crm.generic_email_domains (
  id          uuid primary key default gen_random_uuid(),
  -- Null: a row of the installation, for every company — shipped by the
  -- module or added by whoever runs the installation. A company id: a row
  -- that company added for itself.
  company_id  uuid references public.companies(id) on delete cascade,
  domain      text not null,
  kind        text not null,
  shipped     boolean not null default false,
  note        text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  constraint crm_generic_email_domains_kind check (kind in ('personal', 'tool', 'provider')),
  constraint crm_generic_email_domains_domain_shape
    check (domain ~ '^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)+$'),
  constraint crm_generic_email_domains_shipped_installation check (not shipped or company_id is null)
);

comment on table crm.generic_email_domains is
  'The e-mail domains that never name an organisation: personal mailboxes, tools that send on somebody''s behalf, providers hosting many unrelated organisations. A domain on the list, or any sub-domain of it, is generic: crm.contact_from_email() creates no organisation for it. Rows without a company are the installation''s — shipped by the module, or added by the installation; a company may add its own.';
comment on column crm.generic_email_domains.company_id is
  'Null for a row of the installation, which every company reads; a company id for a row that company added for itself.';
comment on column crm.generic_email_domains.domain is
  'The domain, lower case, without the @. Its sub-domains are generic too.';
comment on column crm.generic_email_domains.kind is
  'Why the domain names nobody: personal (a mailbox anybody can open), tool (a service that sends on somebody''s behalf), provider (a host of many unrelated organisations).';
comment on column crm.generic_email_domains.shipped is
  'True for a row the module''s migrations wrote. A later migration of the module may add rows; it never removes one an installation relies on.';

create unique index crm_generic_email_domains_installation_idx
  on crm.generic_email_domains (domain) where company_id is null;
create unique index crm_generic_email_domains_company_idx
  on crm.generic_email_domains (company_id, domain) where company_id is not null;

create trigger crm_generic_email_domains_set_updated_at
  before update on crm.generic_email_domains
  for each row execute function public.set_updated_at();

alter table crm.generic_email_domains enable row level security;

-- Every member of a company holding the module reads the installation's rows
-- and their company's own. A company writes its own rows with crm.write; the
-- installation's rows are written by the installation (the migration runner,
-- the service role), never by a member.
create policy crm_generic_email_domains_select on crm.generic_email_domains
  for select using (
    company_id is null
    or company_id = any ((select array(
      select x from unnest(public.companies_with_capability('crm.read')) as x where public.module_enabled(x, 'crm')
    ))::uuid[]));
create policy crm_generic_email_domains_write on crm.generic_email_domains
  for all using (company_id = any ((select array(
    select x from unnest(public.companies_with_capability('crm.write')) as x where public.module_enabled(x, 'crm')
  ))::uuid[]))
  with check (public.module_enabled(company_id, 'crm') and public.has_capability(company_id, 'crm.write'));

grant select, insert, update, delete on table crm.generic_email_domains to authenticated, service_role;

-- The list the module ships. Widely used mailboxes and senders, whatever the
-- country of their registry; an installation adds what its users meet.
insert into crm.generic_email_domains (domain, kind, shipped) values
  -- Personal mailboxes
  ('gmail.com', 'personal', true), ('googlemail.com', 'personal', true),
  ('outlook.com', 'personal', true), ('hotmail.com', 'personal', true), ('live.com', 'personal', true),
  ('msn.com', 'personal', true), ('passport.com', 'personal', true),
  ('yahoo.com', 'personal', true), ('ymail.com', 'personal', true), ('rocketmail.com', 'personal', true),
  ('icloud.com', 'personal', true), ('me.com', 'personal', true), ('mac.com', 'personal', true),
  ('aol.com', 'personal', true), ('aim.com', 'personal', true),
  ('proton.me', 'personal', true), ('protonmail.com', 'personal', true), ('protonmail.ch', 'personal', true),
  ('pm.me', 'personal', true),
  ('tutanota.com', 'personal', true), ('tutanota.de', 'personal', true), ('tuta.io', 'personal', true),
  ('tuta.com', 'personal', true),
  ('fastmail.com', 'personal', true), ('fastmail.fm', 'personal', true), ('hey.com', 'personal', true),
  ('zoho.com', 'personal', true), ('zohomail.com', 'personal', true),
  ('gmx.com', 'personal', true), ('gmx.net', 'personal', true), ('gmx.de', 'personal', true),
  ('gmx.at', 'personal', true), ('gmx.ch', 'personal', true), ('gmx.fr', 'personal', true),
  ('mail.com', 'personal', true), ('email.com', 'personal', true), ('web.de', 'personal', true),
  ('t-online.de', 'personal', true), ('freenet.de', 'personal', true),
  ('yandex.com', 'personal', true), ('yandex.ru', 'personal', true), ('ya.ru', 'personal', true),
  ('mail.ru', 'personal', true), ('bk.ru', 'personal', true), ('list.ru', 'personal', true),
  ('inbox.ru', 'personal', true), ('rambler.ru', 'personal', true),
  ('qq.com', 'personal', true), ('163.com', 'personal', true), ('126.com', 'personal', true),
  ('yeah.net', 'personal', true), ('sina.com', 'personal', true), ('sohu.com', 'personal', true),
  ('aliyun.com', 'personal', true),
  ('naver.com', 'personal', true), ('daum.net', 'personal', true), ('hanmail.net', 'personal', true),
  ('rediffmail.com', 'personal', true),
  ('orange.fr', 'personal', true), ('wanadoo.fr', 'personal', true), ('free.fr', 'personal', true),
  ('laposte.net', 'personal', true), ('sfr.fr', 'personal', true), ('neuf.fr', 'personal', true),
  ('bbox.fr', 'personal', true),
  ('skynet.be', 'personal', true), ('telenet.be', 'personal', true), ('proximus.be', 'personal', true),
  ('scarlet.be', 'personal', true),
  ('libero.it', 'personal', true), ('virgilio.it', 'personal', true), ('tiscali.it', 'personal', true),
  ('alice.it', 'personal', true),
  ('bluewin.ch', 'personal', true), ('hispeed.ch', 'personal', true),
  ('ziggo.nl', 'personal', true), ('kpnmail.nl', 'personal', true), ('home.nl', 'personal', true),
  ('planet.nl', 'personal', true),
  ('btinternet.com', 'personal', true), ('sky.com', 'personal', true), ('virginmedia.com', 'personal', true),
  ('talktalk.net', 'personal', true), ('ntlworld.com', 'personal', true),
  ('comcast.net', 'personal', true), ('verizon.net', 'personal', true), ('att.net', 'personal', true),
  ('sbcglobal.net', 'personal', true), ('bellsouth.net', 'personal', true), ('cox.net', 'personal', true),
  ('charter.net', 'personal', true), ('earthlink.net', 'personal', true),
  ('shaw.ca', 'personal', true), ('rogers.com', 'personal', true), ('sympatico.ca', 'personal', true),
  ('videotron.ca', 'personal', true),
  ('bigpond.com', 'personal', true), ('optusnet.com.au', 'personal', true),
  ('uol.com.br', 'personal', true), ('bol.com.br', 'personal', true), ('terra.com.br', 'personal', true),
  ('seznam.cz', 'personal', true), ('wp.pl', 'personal', true), ('o2.pl', 'personal', true),
  ('onet.pl', 'personal', true), ('interia.pl', 'personal', true),
  ('mail.ee', 'personal', true), ('abv.bg', 'personal', true), ('ukr.net', 'personal', true),
  ('sapo.pt', 'personal', true), ('telefonica.net', 'personal', true),
  -- Tools that send on somebody's behalf
  ('docusign.net', 'tool', true), ('echosign.com', 'tool', true),
  ('sendgrid.net', 'tool', true), ('amazonses.com', 'tool', true), ('mailgun.org', 'tool', true),
  ('mcsv.net', 'tool', true), ('mandrillapp.com', 'tool', true), ('sparkpostmail.com', 'tool', true),
  ('mailchimpapp.net', 'tool', true), ('hubspotemail.net', 'tool', true),
  ('users.noreply.github.com', 'tool', true),
  ('guerrillamail.com', 'tool', true), ('mailinator.com', 'tool', true), ('yopmail.com', 'tool', true),
  -- Providers hosting many unrelated organisations under one domain
  ('onmicrosoft.com', 'provider', true), ('privaterelay.appleid.com', 'provider', true),
  ('duck.com', 'provider', true), ('simplelogin.com', 'provider', true), ('anonaddy.me', 'provider', true)
on conflict (domain) where company_id is null do nothing;

-- ---------------------------------------------------------------------------
-- 2. Reading an address
-- ---------------------------------------------------------------------------

create or replace function crm.email_address(p_text text)
returns text
language sql
immutable
as $$
  select nullif(rtrim(lower((regexp_match(
    p_text,
    '([^\s<>"''(),;:@\[\]]+@[^\s<>"''(),;:@\[\]]+\.[^\s<>"''(),;:@\[\]]+)'
  ))[1]), '.'), '');
$$;

comment on function crm.email_address(text) is
  'The first e-mail address found in a text, lower case — from a bare address, from "Name <address>", or from the first of a list. Null when the text holds none.';

create or replace function crm.email_domain(p_text text)
returns text
language sql
immutable
as $$
  select nullif(split_part(crm.email_address(p_text), '@', 2), '');
$$;

comment on function crm.email_domain(text) is
  'The domain of the first e-mail address found in a text, lower case, without the @. Null when the text holds no address.';

create or replace function crm.is_generic_email_domain(p_company_id uuid, p_domain text)
returns boolean
language sql
stable
as $$
  select exists (
    select 1 from crm.generic_email_domains g
     where (g.company_id is null or g.company_id = p_company_id)
       and (lower(p_domain) = g.domain or lower(p_domain) like '%.' || g.domain));
$$;

comment on function crm.is_generic_email_domain(uuid, text) is
  'Whether a domain names no organisation for a company: it, or a domain it is a sub-domain of, is on crm.generic_email_domains — among the installation''s rows or the company''s own.';

create or replace function crm.organisation_of_domain(p_company_id uuid, p_domain text)
returns uuid
language plpgsql
stable
as $$
declare
  v_id uuid;
begin
  -- An organisation whose own address is at the domain: the company said so.
  select o.id into v_id
    from public.contacts o
   where o.company_id = p_company_id and o.is_company and o.merged_into is null
     and o.email ilike '%@' || p_domain || '%'
     and crm.email_domain(o.email) = p_domain
   order by o.active desc, o.created_at, o.id
   limit 1;
  if found then
    return v_id;
  end if;
  -- Else the organisation most of the people writing from the domain belong to.
  select p.parent_id into v_id
    from public.contacts p
    join public.contacts o on o.id = p.parent_id and o.company_id = p.company_id
   where p.company_id = p_company_id and not p.is_company and p.merged_into is null
     and o.is_company and o.merged_into is null
     and p.email ilike '%@' || p_domain || '%'
     and crm.email_domain(p.email) = p_domain
   group by p.parent_id
   order by count(*) desc, min(o.created_at), p.parent_id
   limit 1;
  return v_id;
end;
$$;

comment on function crm.organisation_of_domain(uuid, text) is
  'The organisation of a company an e-mail domain belongs to: the organisation whose own address is at the domain, else the one most of the people writing from it belong to. Null when none. Merged contacts are left out.';

-- ---------------------------------------------------------------------------
-- 3. A contact, and its organisation, from an address
-- ---------------------------------------------------------------------------

create or replace function crm.contact_from_email(
  p_company_id uuid,
  p_email      text,
  p_name       text default null,
  p_source     text default null
)
returns jsonb
language plpgsql
as $$
declare
  v_address     text := crm.email_address(p_email);
  v_domain      text;
  v_generic     boolean;
  v_contact     public.contacts%rowtype;
  v_org         uuid;
  v_created     boolean := false;
  v_org_created boolean := false;
  v_n           integer;
begin
  perform crm.require(p_company_id, 'crm.write', 'finding a contact from an e-mail');
  if v_address is null then
    raise exception 'crm_bad_email: % holds no e-mail address', coalesce(p_email, 'null');
  end if;
  v_domain  := split_part(v_address, '@', 2);
  v_generic := crm.is_generic_email_domain(p_company_id, v_domain);

  -- One writer per domain at a time: two e-mails from the same new address,
  -- or from two new people of one organisation, arriving together, create one
  -- contact and one organisation.
  perform pg_advisory_xact_lock(hashtextextended('crm.contact_from_email:' || p_company_id::text || ':' || v_domain, 0));

  -- The contact already on file at that address: a person before an
  -- organisation, an active one before an archived one, the oldest first.
  select * into v_contact
    from public.contacts c
   where c.company_id = p_company_id and c.merged_into is null
     and c.email ilike '%' || v_address || '%'
     and crm.email_address(c.email) = v_address
   order by c.is_company, c.active desc, c.created_at, c.id
   limit 1;

  -- The organisation: the contact itself when it is one, the one a person on
  -- file already belongs to, else the one of the domain — never a generic one.
  if v_contact.id is not null and v_contact.is_company then
    v_org := v_contact.id;
  elsif v_contact.id is not null and v_contact.parent_id is not null then
    v_org := v_contact.parent_id;
  elsif not v_generic then
    v_org := crm.organisation_of_domain(p_company_id, v_domain);
  end if;

  if v_contact.id is null or (v_org is null and not v_generic) then
    if not public.is_installer() and not public.has_capability(p_company_id, 'contacts.write') then
      raise exception 'crm_not_allowed: creating the contact of % needs contacts.write', v_address
        using errcode = '42501';
    end if;
  end if;

  if v_org is null and not v_generic then
    insert into public.contacts (company_id, name, is_company, contact_type)
    values (p_company_id, v_domain, true, 'other')
    returning id into v_org;
    v_org_created := true;
  end if;

  if v_contact.id is null then
    insert into public.contacts (company_id, name, is_company, contact_type, parent_id, email)
    values (p_company_id, coalesce(nullif(btrim(p_name), ''), v_address), false, 'other', v_org, v_address)
    returning * into v_contact;
    v_created := true;
  elsif not v_contact.is_company and v_contact.parent_id is null and v_org is not null then
    -- A person on file with no organisation yet: the domain gives it one.
    update public.contacts c set parent_id = v_org
     where c.id = v_contact.id and c.company_id = p_company_id;
    get diagnostics v_n = row_count;
    if v_n = 0 then
      raise exception 'crm_not_allowed: giving % its organisation needs contacts.write', v_address
        using errcode = '42501';
    end if;
    v_contact.parent_id := v_org;
  end if;

  -- Both are followed from now on. A card already there is left as it is.
  insert into crm.cards (company_id, contact_id, source)
  select p_company_id, x.id, p_source
    from (values (v_contact.id), (v_org)) as x(id)
   where x.id is not null
  on conflict (company_id, contact_id) do nothing;

  return jsonb_build_object(
    'contact_id', v_contact.id,
    'organisation_id', case when v_contact.is_company then v_contact.id else v_contact.parent_id end,
    'address', v_address,
    'domain', v_domain,
    'generic_domain', v_generic,
    'contact_created', v_created,
    'organisation_created', v_org_created);
end;
$$;

comment on function crm.contact_from_email(uuid, text, text, text) is
  'The contact an e-mail address belongs to, found or created, and its organisation, found or created by the domain of the address: the organisation whose own address is at the domain, else the one most of its people belong to, else a new organisation named by the domain. A generic domain (crm.generic_email_domains) never makes an organisation. A person on file without an organisation gets the one of its domain; nothing else on file changes. Both get a card when they have none, with p_source as its source. Never creates a second contact for an address already on file — two contacts that are one party are joined by merge_contacts(). Creating a contact needs contacts.write besides crm.write. Returns contact_id, organisation_id, address, domain, generic_domain, contact_created and organisation_created.';

create or replace function crm.log_activity_by_email(
  p_company_id  uuid,
  p_email       text,
  p_kind        crm.activity_kind,
  p_subject     text default null,
  p_body        text default null,
  p_deal_id     uuid default null,
  p_actor       text default null,
  p_occurred_at timestamptz default null,
  p_link        text default null,
  p_payload     jsonb default null,
  p_source      text default null,
  p_source_ref  text default null,
  p_name        text default null
)
returns jsonb
language plpgsql
as $$
declare
  v_row      crm.activities%rowtype;
  v_resolved jsonb;
begin
  perform crm.require(p_company_id, 'crm.write', 'logging an activity');

  -- Read from elsewhere, and already written: the activity that is there,
  -- and nothing looked up or created again.
  if p_source is not null and p_source_ref is not null then
    select * into v_row from crm.activities a
     where a.company_id = p_company_id and a.source = p_source and a.source_ref = p_source_ref;
    if found then
      return jsonb_build_object(
        'activity', to_jsonb(v_row),
        'contact_id', v_row.contact_id,
        'organisation_id', (select case when c.is_company then c.id else c.parent_id end
                              from public.contacts c where c.id = v_row.contact_id and c.company_id = p_company_id),
        'contact_created', false,
        'organisation_created', false,
        'replayed', true);
    end if;
  end if;

  v_resolved := crm.contact_from_email(p_company_id, p_email, p_name, p_source);
  v_row := crm.log_activity(p_company_id, (v_resolved ->> 'contact_id')::uuid, p_kind, p_subject, p_body, p_deal_id,
                            p_actor, p_occurred_at, p_link, p_payload, p_source, p_source_ref);
  return v_resolved || jsonb_build_object('activity', to_jsonb(v_row), 'replayed', false);
end;
$$;

comment on function crm.log_activity_by_email(uuid, text, crm.activity_kind, text, text, uuid, text, timestamptz, text, jsonb, text, text, text) is
  'Writes one activity named by an e-mail address rather than by a contact: the contact and its organisation are found or created by crm.contact_from_email() (p_name names a new contact), then the activity is written by crm.log_activity(). The same (source, source_ref) a second time writes nothing, looks nothing up, and returns the activity already kept with replayed true. Needs crm.write, and contacts.write to create a contact. Returns the activity, contact_id, organisation_id, contact_created, organisation_created and replayed.';

-- ---------------------------------------------------------------------------
-- 4. The first and the last interaction, computed
-- ---------------------------------------------------------------------------

create or replace function crm.interactions_of(p_company_id uuid, p_contact_ids uuid[])
returns table (
  contact_id           uuid,
  first_interaction_at timestamptz,
  last_interaction_at  timestamptz,
  interactions         bigint
)
language sql
stable
as $$
  with wanted as (
    select distinct w as contact_id from unnest(p_contact_ids) as w where w is not null
  ),
  -- An organisation's interactions are its own and those of its people.
  members as (
    select w.contact_id as card_contact_id, w.contact_id as activity_contact_id from wanted w
    union
    select w.contact_id, c.id
      from wanted w
      join public.contacts c on c.parent_id = w.contact_id and c.company_id = p_company_id
  )
  select m.card_contact_id, min(a.occurred_at), max(a.occurred_at), count(*)
    from members m
    join crm.activities a on a.contact_id = m.activity_contact_id and a.company_id = p_company_id
   -- An interaction is an exchange with the contact. A note, a signal, an
   -- enrichment, a task and what the module writes itself are not.
   where a.kind in ('email_in', 'email_out', 'call', 'meeting', 'message')
   group by m.card_contact_id;
$$;

comment on function crm.interactions_of(uuid, uuid[]) is
  'For each contact named, its first and last interaction and how many there were, computed from crm.activities whenever it is read — the one source of these dates. An interaction is an e-mail in or out, a call, a meeting or a message; for an organisation, its people''s count too. A contact with none is absent. last_activity_at on the card is another fact: the latest activity of any kind.';

-- crm.card_of(), as 20261118145000 left it, with the interactions on the card.
create or replace function crm.card_of(p_company_id uuid, p_contact_id uuid)
returns jsonb
language plpgsql
stable
as $$
declare
  v_contact public.contacts%rowtype;
  v_out     jsonb;
begin
  perform crm.require(p_company_id, 'crm.read', 'reading a card');
  select * into v_contact from public.contacts c where c.id = p_contact_id and c.company_id = p_company_id;
  if not found then
    raise exception 'crm_unknown_contact: contact % is not a contact of company %', p_contact_id, p_company_id;
  end if;

  select jsonb_build_object(
    'contact', jsonb_build_object(
      'id', v_contact.id, 'name', v_contact.name, 'is_company', v_contact.is_company,
      'contact_type', v_contact.contact_type, 'parent_id', v_contact.parent_id,
      'email', v_contact.email, 'phone', v_contact.phone, 'city', v_contact.city,
      'country', v_contact.country, 'language', v_contact.language,
      'vat_number', v_contact.vat_number, 'active', v_contact.active),
    'organisation', (select jsonb_build_object('id', o.id, 'name', o.name, 'contact_type', o.contact_type)
                       from public.contacts o
                      where o.id = v_contact.parent_id and o.company_id = p_company_id),
    'card', (select to_jsonb(k) || jsonb_build_object(
                      'first_interaction_at', i.first_interaction_at,
                      'last_interaction_at', i.last_interaction_at,
                      'interactions', coalesce(i.interactions, 0))
               from crm.cards k
               left join crm.interactions_of(p_company_id, array[p_contact_id]) i on true
              where k.contact_id = p_contact_id and k.company_id = p_company_id),
    'segments', coalesce((select jsonb_agg(jsonb_build_object('id', s.id, 'slug', s.slug, 'name', s.name,
                                                               'kind', s.kind, 'joined_at', m.joined_at)
                                           order by s.slug)
                            from crm.segment_members m
                            join crm.segments s on s.id = m.segment_id and s.company_id = m.company_id
                           where m.contact_id = p_contact_id and m.company_id = p_company_id
                             and m.left_at is null), '[]'::jsonb),
    -- An organisation's deals include those with its people.
    'deals', coalesce((select jsonb_agg(jsonb_build_object('id', d.id, 'title', d.title, 'contact_id', d.contact_id,
                                                            'pipeline_id', d.pipeline_id, 'stage_id', d.stage_id,
                                                            'stage', st.name, 'amount', d.amount,
                                                            'currency_code', d.currency_code,
                                                            'expected_on', d.expected_on, 'owner', d.owner,
                                                            'documents', crm.deal_documents_of(p_company_id, d.id))
                                         order by d.created_at)
                         from crm.deals d
                         join crm.stages st on st.id = d.stage_id
                        where d.company_id = p_company_id and d.closed_at is null
                          and (d.contact_id = p_contact_id
                               or d.contact_id in (select c.id from public.contacts c
                                                    where c.parent_id = p_contact_id and c.company_id = p_company_id))),
                      '[]'::jsonb),
    'activities', coalesce((select jsonb_agg(to_jsonb(a) order by a.occurred_at desc, a.created_at desc)
                              from (select * from crm.activities a
                                     where a.company_id = p_company_id and a.contact_id = p_contact_id
                                     order by a.occurred_at desc, a.created_at desc
                                     limit 20) a), '[]'::jsonb)
  ) into v_out;
  return v_out;
end;
$$;

comment on function crm.card_of(uuid, uuid) is
  'Everything on one contact, as one JSON object: the contact as the socle holds it, its organisation, its card — with first_interaction_at, last_interaction_at and interactions computed by crm.interactions_of() — the segments it is in now, the open deals with it — and, for an organisation, with its people — each with the documents it carries and their quote_status (crm.deal_documents_of()), and its 20 latest activities. Needs crm.read.';

-- ---------------------------------------------------------------------------
-- 5. The archive of a company carries its own generic domains
-- ---------------------------------------------------------------------------

create or replace function crm.archive_tables()
returns table (
  table_name  text,
  disposition text,
  reason      text,
  via_column  text,
  via_table   text,
  load_order  integer
)
language sql
immutable
as $$
  values
    ('pipelines'::text,       'exported'::text, null::text, null::text, null::text, 1),
    ('stages',                'exported',       null,       null,       null,       2),
    ('segments',              'exported',       null,       null,       null,       3),
    ('cards',                 'exported',       null,       null,       null,       4),
    ('segment_members',       'exported',       null,       null,       null,       5),
    ('deals',                 'exported',       null,       null,       null,       6),
    ('activities',            'exported',       null,       null,       null,       7),
    ('deal_documents',        'exported',       null,       null,       null,       8),
    ('generic_email_domains', 'exported',       null,       null,       null,       9);
$$;

comment on function crm.archive_tables() is
  'What an archive of one company does with each table of this module: all nine travel — a relationship is the company''s as much as its books, the documents its deals carry with it, and the generic e-mail domains the company added for itself (the installation''s rows belong to no company). Read by `public.company_archive_tables()`.';

-- ---------------------------------------------------------------------------
-- 6. Privileges, by name
-- ---------------------------------------------------------------------------

revoke execute on function crm.email_address(text) from public, anon;
revoke execute on function crm.email_domain(text) from public, anon;
revoke execute on function crm.is_generic_email_domain(uuid, text) from public, anon;
revoke execute on function crm.organisation_of_domain(uuid, text) from public, anon;
revoke execute on function crm.contact_from_email(uuid, text, text, text) from public, anon;
revoke execute on function crm.log_activity_by_email(uuid, text, crm.activity_kind, text, text, uuid, text, timestamptz, text, jsonb, text, text, text) from public, anon;
revoke execute on function crm.interactions_of(uuid, uuid[]) from public, anon;
revoke execute on function crm.card_of(uuid, uuid) from public, anon;
revoke execute on function crm.archive_tables() from public, anon;

grant execute on function crm.email_address(text) to authenticated, service_role;
grant execute on function crm.email_domain(text) to authenticated, service_role;
grant execute on function crm.is_generic_email_domain(uuid, text) to authenticated, service_role;
grant execute on function crm.organisation_of_domain(uuid, text) to authenticated, service_role;
grant execute on function crm.contact_from_email(uuid, text, text, text) to authenticated, service_role;
grant execute on function crm.log_activity_by_email(uuid, text, crm.activity_kind, text, text, uuid, text, timestamptz, text, jsonb, text, text, text) to authenticated, service_role;
grant execute on function crm.interactions_of(uuid, uuid[]) to authenticated, service_role;
grant execute on function crm.card_of(uuid, uuid) to authenticated, service_role;
grant execute on function crm.archive_tables() to authenticated, service_role;
