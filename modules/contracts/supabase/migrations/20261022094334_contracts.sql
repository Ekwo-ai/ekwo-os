-- Ekwo — the `contracts` module: what a company has agreed with another party,
-- and the invoices that agreement says are due.
--
-- A contract names one party of `public.contacts` — a customer when the
-- company sells, a supplier when it buys — and holds what was agreed: its
-- kind, its dates, how it renews and with how much notice, its value in a
-- currency, the signed file. Its schedules are the lines it invoices, each at
-- its own rhythm; `contracts.issue_due()` turns every period that has come
-- into one draft document of the socle — a sales invoice or a purchase
-- invoice, `contract_reference` (EN 16931 BT-12) filled with the contract's
-- number — and records which period that document covers. Its amendments
-- say what changed and from when; its templates are the clauses and the
-- schedule a contract starts from.
--
-- **The module never writes the ledger.** An issue is a draft document,
-- written in `public.documents` the way a person writes one, under the same
-- policies. A schedule with `auto_post` asks the socle's `post_document()` to
-- book the draft, as a person with `documents.post` would; the entry is the
-- socle's, built by the socle's rules. `module.json` says `"posts": false`,
-- and a test holds it to never calling `post_module_entry()`.
--
-- **Idempotent because the socle refuses the duplicate.** The draft of a
-- period carries `client_ref = contracts:<schedule>:<first day>`, unique per
-- company in `public.documents`, and `contracts.issues` is unique per
-- (schedule, first day of the period). Calling `issue_due()` twice for one day
-- issues once; two callers at once wait on the schedule's lock.
--
-- **Every reference is composite with `company_id`**, as in `crm`: a row of one
-- company can never name a contact, a product, a contract or a document of
-- another, whatever id it is handed.
--
-- **The functions are `security invoker`.** The policies decide every row;
-- `contracts.require()` answers by name first, `contracts_<code>: <sentence>`.
--
-- **No country, no currency, no language.** A contract's currency is the
-- company's unless another is named, read from `public.companies` and never
-- written as a default; a tax is named by its code in the company's own list;
-- an account is resolved by the socle, from the product or the company's
-- defaults, never here.

create schema contracts;

comment on schema contracts is
  'Ekwo module `contracts`: what a company agreed with another party — dates, renewal, notice, value, the signed file — its schedules, the draft invoices they issue, its amendments and the templates a contract starts from. Never writes the ledger.';

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------

create type contracts.contract_kind as enum ('service', 'licence', 'subscription', 'usage', 'one_time', 'other');

comment on type contracts.contract_kind is
  'What a contract is about. service: work done for the other party. licence: a right to use something. subscription: access for as long as it runs. usage: billed on what was used. one_time: one delivery, one invoice. other: none of these.';

create type contracts.direction as enum ('sale', 'purchase');

comment on type contracts.direction is
  'Which side the company is on. sale: the company supplies and invoices; the other party is a customer. purchase: the company buys and is invoiced; the other party is a supplier.';

create type contracts.contract_state as enum (
  'draft', 'sent', 'negotiation', 'signed', 'active', 'expired', 'terminated', 'cancelled'
);

comment on type contracts.contract_state is
  'Where a contract stands. draft: being written. sent: handed to the other party. negotiation: being discussed. signed: agreed, not started yet. active: running. expired: ended on its date. terminated: ended by one of the parties. cancelled: never ran. A contract moves forward only; the last three are final.';

create type contracts.renewal as enum ('none', 'tacit');

comment on type contracts.renewal is
  'What happens at the end. none: the contract expires. tacit: it renews for the length of the term that ends, unless notice was given before the notice date.';

create type contracts.frequency as enum ('weekly', 'monthly', 'quarterly', 'yearly');

comment on type contracts.frequency is
  'How often a schedule issues: every week, month, three months or year, counted from the first period so that a schedule on the 31st stays on the last day of shorter months.';

create type contracts.amendment_kind as enum ('version', 'amendment', 'renewal');

comment on type contracts.amendment_kind is
  'What an amendment is. version: another text of the contract, before or as it is signed, with its file. amendment: a change agreed after signing, applied to the contract and its schedules. renewal: a tacit renewal, written by contracts.roll_forward() and by nobody else.';

create type contracts.template_format as enum ('html', 'docx');

comment on type contracts.template_format is
  'How a template holds its clauses. html: the text itself, with {{variables}}, in contracts.templates.html. docx: a word-processing file with the same variables, kept as an attachment of the socle.';

-- ---------------------------------------------------------------------------
-- Templates
-- ---------------------------------------------------------------------------

create table contracts.templates (
  id            uuid primary key default gen_random_uuid(),
  company_id    uuid not null references public.companies(id) on delete cascade,
  name          text not null,
  description   text,
  category      text,
  format        contracts.template_format not null,
  html          text,
  attachment_id uuid references public.attachments(id) on delete restrict,
  variables     jsonb not null default '[]'::jsonb,
  schedule      jsonb not null default '[]'::jsonb,
  active        boolean not null default true,
  created_by    uuid default auth.uid(),
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  constraint contracts_templates_id_company_key unique (id, company_id),
  constraint contracts_templates_name check (length(btrim(name)) > 0),
  constraint contracts_templates_html check (format <> 'html' or html is not null),
  constraint contracts_templates_docx check (format <> 'docx' or attachment_id is not null),
  constraint contracts_templates_variables_array check (jsonb_typeof(variables) = 'array'),
  constraint contracts_templates_schedule_array check (jsonb_typeof(schedule) = 'array')
);

comment on table contracts.templates is
  'What a contract starts from: its clauses — an html text or a docx file — with the variables they name, a category, and a template schedule. contracts.from_template() makes a draft contract of one.';
comment on column contracts.templates.category is
  'How the company files its templates — services, licences, employment, confidentiality — in its own words.';
comment on column contracts.templates.html is
  'The clauses as html, with {{key}} where a variable goes. Required when format is html.';
comment on column contracts.templates.attachment_id is
  'The docx file of the clauses, an attachment of the socle with its checksum. Required when format is docx.';
comment on column contracts.templates.variables is
  'The variables the clauses name, as a JSON array of objects: {"key": …, "label": …, "type": …, "required": true|false, "default_value": …}. contracts.from_template() refuses a required one left empty.';
comment on column contracts.templates.schedule is
  'The schedule a contract made from this template starts with, as a JSON array of the fields contracts.upsert_schedule() takes: {"name", "product_code", "quantity", "unit_code", "unit_price", "tax_code", "frequency", "auto_post"}.';
comment on column contracts.templates.created_by is
  'auth.users.id of whoever wrote the template. No foreign key, as company_members has none.';

create index contracts_templates_company_idx on contracts.templates (company_id);
create index contracts_templates_attachment_idx on contracts.templates (attachment_id);

create trigger contracts_templates_set_updated_at
  before update on contracts.templates
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Contracts
-- ---------------------------------------------------------------------------

create table contracts.contracts (
  id            uuid primary key default gen_random_uuid(),
  company_id    uuid not null references public.companies(id) on delete cascade,
  contact_id    uuid not null,
  number        text not null,
  name          text not null,
  kind          contracts.contract_kind not null,
  direction     contracts.direction not null,
  state         contracts.contract_state not null default 'draft',
  signed_on     date,
  starts_on     date,
  ends_on       date,
  renews_on     date,
  renewal       contracts.renewal not null default 'none',
  notice_days   integer,
  -- The company's currency unless another is named, written by the trigger
  -- below: never a default of the column.
  currency_code char(3) not null references public.currencies (code),
  total_value   numeric(18, 2),
  attachment_id uuid references public.attachments(id) on delete restrict,
  template_id   uuid,
  notes         text,
  analysis      jsonb not null default '{}'::jsonb,
  attributes    jsonb not null default '{}'::jsonb,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  -- The company leads the key: a number already used by another company is
  -- not this one's business.
  unique (company_id, number),
  constraint contracts_contracts_id_company_key unique (id, company_id),
  foreign key (contact_id, company_id) references public.contacts (id, company_id),
  foreign key (template_id, company_id) references contracts.templates (id, company_id),
  constraint contracts_contracts_number check (length(btrim(number)) > 0),
  constraint contracts_contracts_name check (length(btrim(name)) > 0),
  constraint contracts_contracts_dates check (ends_on is null or starts_on is null or ends_on >= starts_on),
  constraint contracts_contracts_tacit check (renewal <> 'tacit' or (starts_on is not null and ends_on is not null)),
  constraint contracts_contracts_notice check (notice_days is null or notice_days >= 0),
  constraint contracts_contracts_value check (total_value is null or total_value >= 0),
  constraint contracts_contracts_analysis_object check (jsonb_typeof(analysis) = 'object'),
  constraint contracts_contracts_attributes_object check (jsonb_typeof(attributes) = 'object')
);

comment on table contracts.contracts is
  'One agreement with one party of the books: what it is about, which side the company is on, where it stands, its dates, how it renews and with how much notice, its value in its currency, the signed file. Its number is the company''s own, unique in the company, and is written on every document it issues (contract_reference, EN 16931 BT-12).';
comment on column contracts.contracts.contact_id is
  'The other party: a customer on a sale, a supplier on a purchase. A row of public.contacts of the same company.';
comment on column contracts.contracts.number is
  'The company''s reference for the contract, unique in the company. Copied onto every document the contract issues, as contract_reference.';
comment on column contracts.contracts.signed_on is
  'The day it was signed. Written with the day a contract reaches signed when nobody gave one.';
comment on column contracts.contracts.ends_on is
  'The last day of the current term. Null: open-ended, it runs until it is terminated.';
comment on column contracts.contracts.renews_on is
  'The first day of the next term, when the contract renews. Set to the day after ends_on for a tacit renewal when nobody gave one, and moved with it.';
comment on column contracts.contracts.notice_days is
  'How many days before the next term — or before the end, where it does not renew — notice has to be given. The notice deadline of contracts.deadlines is that day.';
comment on column contracts.contracts.currency_code is
  'The currency of its value and of the documents it issues. The company''s own when the contract was created without one.';
comment on column contracts.contracts.total_value is
  'What the contract is worth over its term, excluding tax, as the parties said it. A figure of the agreement, never added to the books.';
comment on column contracts.contracts.attachment_id is
  'The signed file: an attachment of the socle, with its checksum, of the same company. The file itself is filed on the other party (entity_type contact).';
comment on column contracts.contracts.template_id is
  'The template it was made from, if any.';
comment on column contracts.contracts.notes is
  'What somebody — a member, an agent — wrote about the contract: its risks, what to watch.';
comment on column contracts.contracts.analysis is
  'A structured reading of the contract, as a JSON object: its key clauses, its obligations, a level of risk. Written by whoever read it; the module only keeps it.';
comment on column contracts.contracts.attributes is
  'The fields a company keeps that the module does not name, as a JSON object. contracts.from_template() writes the template variables here, under "variables".';

create index contracts_contracts_contact_company_idx on contracts.contracts (contact_id, company_id);
create index contracts_contracts_template_company_idx on contracts.contracts (template_id, company_id);
create index contracts_contracts_company_state_idx on contracts.contracts (company_id, state);
create index contracts_contracts_attachment_idx on contracts.contracts (attachment_id);
create index contracts_contracts_currency_idx on contracts.contracts (currency_code);

create trigger contracts_contracts_set_updated_at
  before update on contracts.contracts
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Schedules
-- ---------------------------------------------------------------------------

create table contracts.schedules (
  id          uuid primary key default gen_random_uuid(),
  company_id  uuid not null references public.companies(id) on delete cascade,
  contract_id uuid not null,
  sequence    integer not null default 10,
  product_id  uuid,
  name        text not null,
  description text,
  quantity    numeric(16, 4) not null default 1,
  -- UN/ECE Recommendation 20, BT-130, as on a document line: C62 is "one".
  unit_code   text not null default 'C62',
  unit_price  numeric(16, 6) not null,
  tax_code    text,
  frequency   contracts.frequency not null,
  next_on     date not null,
  until       date,
  indexation  jsonb,
  auto_post   boolean not null default false,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  constraint contracts_schedules_id_company_key unique (id, company_id),
  foreign key (contract_id, company_id) references contracts.contracts (id, company_id) on delete cascade,
  foreign key (product_id, company_id) references public.products (id, company_id),
  constraint contracts_schedules_name check (length(btrim(name)) > 0),
  constraint contracts_schedules_quantity check (quantity > 0),
  constraint contracts_schedules_price check (unit_price >= 0),
  constraint contracts_schedules_unit check (unit_code ~ '^[A-Z0-9]{1,3}$')
);

comment on table contracts.schedules is
  'A line a contract invoices, at its own rhythm: what (a product, or a name), how many, in which unit, at what price, under which tax, every week, month, quarter or year from next_on until until. Each period that has come is issued as one draft document by contracts.issue_due().';
comment on column contracts.schedules.product_id is
  'The catalogue row the line was filled in from, when there is one. Its name, unit, price and tax pre-fill the schedule when it is created; the account of the line is the product''s, resolved by the socle.';
comment on column contracts.schedules.unit_price is
  'The price of one unit, excluding tax, in the contract''s currency. The product''s price for the side of the contract when it is created from a product without one.';
comment on column contracts.schedules.tax_code is
  'The tax of the line, by its code in the company''s list of taxes (public.taxes.code). Null: no tax on the line. Read at each issue, so a tax that changed its rate under the same code is applied as it stands.';
comment on column contracts.schedules.next_on is
  'The first day of the next period to issue. contracts.issue_due() issues every period whose first day is on or before the day it is given, and moves this to the period after.';
comment on column contracts.schedules.until is
  'The last day a period may start on. Null: as long as the contract runs.';
comment on column contracts.schedules.indexation is
  'How the price is indexed, as data, never as code: a JSON object {"index": the name of the index, "formula": the clause as the contract writes it, "base": the value of the index the price was set on, "base_on": its date, "next_on": the day the next indexation is due}. Nothing is computed from it: the deadline is shown in contracts.deadlines, and the new price is an amendment.';
comment on column contracts.schedules.auto_post is
  'True: the documents this schedule issues are booked as soon as they are written, by the socle''s post_document(), which needs documents.post. False: they stay drafts for somebody to read.';

create index contracts_schedules_contract_company_idx on contracts.schedules (contract_id, company_id);
create index contracts_schedules_product_company_idx on contracts.schedules (product_id, company_id);
create index contracts_schedules_company_next_idx on contracts.schedules (company_id, next_on);

create trigger contracts_schedules_set_updated_at
  before update on contracts.schedules
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Issues
-- ---------------------------------------------------------------------------

create table contracts.issues (
  id           uuid primary key default gen_random_uuid(),
  company_id   uuid not null references public.companies(id) on delete cascade,
  contract_id  uuid not null,
  schedule_id  uuid not null,
  document_id  uuid not null,
  period_start date not null,
  period_end   date not null,
  created_at   timestamptz not null default now(),
  -- One document per schedule and period, and the company leads the key.
  unique (company_id, schedule_id, period_start),
  foreign key (contract_id, company_id) references contracts.contracts (id, company_id) on delete cascade,
  foreign key (schedule_id, company_id) references contracts.schedules (id, company_id) on delete cascade,
  -- A draft deleted by its reader takes its issue with it.
  foreign key (document_id, company_id) references public.documents (id, company_id) on delete cascade,
  constraint contracts_issues_period check (period_end >= period_start)
);

comment on table contracts.issues is
  'Which document of the socle a schedule issued for which period: one row per schedule and first day of a period, written by contracts.issue_due(). A draft that is deleted takes its row with it.';

create index contracts_issues_contract_company_idx on contracts.issues (contract_id, company_id);
create index contracts_issues_schedule_company_idx on contracts.issues (schedule_id, company_id);
create index contracts_issues_document_company_idx on contracts.issues (document_id, company_id);

-- ---------------------------------------------------------------------------
-- Amendments
-- ---------------------------------------------------------------------------

create table contracts.amendments (
  id            uuid primary key default gen_random_uuid(),
  company_id    uuid not null references public.companies(id) on delete cascade,
  contract_id   uuid not null,
  number        integer not null,
  kind          contracts.amendment_kind not null,
  summary       text not null,
  changes       jsonb not null default '{}'::jsonb,
  effective_on  date not null,
  signed_on     date,
  attachment_id uuid references public.attachments(id) on delete restrict,
  created_by    uuid default auth.uid(),
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  unique (company_id, contract_id, number),
  foreign key (contract_id, company_id) references contracts.contracts (id, company_id) on delete cascade,
  constraint contracts_amendments_number check (number > 0),
  constraint contracts_amendments_summary check (length(btrim(summary)) > 0),
  constraint contracts_amendments_changes_object check (jsonb_typeof(changes) = 'object')
);

comment on table contracts.amendments is
  'Every text a contract had and every change made to it, numbered from 1 in the contract: a version of the text with its file, an amendment — what changes, from when, signed when, with the signed file — or a tacit renewal.';
comment on column contracts.amendments.number is
  'The place of the row in the contract''s history, 1 first. A version keeps the number its file had.';
comment on column contracts.amendments.summary is
  'What changes, in words.';
comment on column contracts.amendments.changes is
  'What changes, as data: the fields of the contract that took a new value, and under "schedules" the fields of each schedule, by id. Empty for a version.';
comment on column contracts.amendments.effective_on is
  'From when the change holds: the first day of the new term for a renewal.';
comment on column contracts.amendments.attachment_id is
  'The file of this version or of the signed amendment: an attachment of the socle, with its checksum.';
comment on column contracts.amendments.created_by is
  'auth.users.id of whoever recorded it; null for a renewal written by the module.';

create index contracts_amendments_contract_company_idx on contracts.amendments (contract_id, company_id);
create index contracts_amendments_attachment_idx on contracts.amendments (attachment_id);

create trigger contracts_amendments_set_updated_at
  before update on contracts.amendments
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Triggers of the module
-- ---------------------------------------------------------------------------

create or replace function contracts.guard_attachment()
returns trigger
language plpgsql
as $$
declare
  v_id uuid := (to_jsonb(new) ->> 'attachment_id')::uuid;
begin
  if v_id is not null
     and not exists (select 1 from public.attachments a where a.id = v_id and a.company_id = new.company_id) then
    raise exception 'contracts_unknown_attachment: attachment % is not a file of company %', v_id, new.company_id
      using errcode = '23503';
  end if;
  return new;
end;
$$;

comment on function contracts.guard_attachment() is
  'Refuses a file that is not an attachment of the row''s own company (contracts_unknown_attachment): public.attachments has no composite key to name, so the company is checked here.';

create trigger contracts_templates_guard_attachment
  before insert or update of attachment_id on contracts.templates
  for each row execute function contracts.guard_attachment();
create trigger contracts_contracts_guard_attachment
  before insert or update of attachment_id on contracts.contracts
  for each row execute function contracts.guard_attachment();
create trigger contracts_amendments_guard_attachment
  before insert or update of attachment_id on contracts.amendments
  for each row execute function contracts.guard_attachment();

create or replace function contracts.state_rank(p_state contracts.contract_state)
returns integer
language sql
immutable
as $$
  select case p_state
           when 'draft' then 0 when 'sent' then 1 when 'negotiation' then 2
           when 'signed' then 3 when 'active' then 4 else 5 end;
$$;

comment on function contracts.state_rank(contracts.contract_state) is
  'The order a contract moves in: draft, sent, negotiation, signed, active, then the three final states.';

create or replace function contracts.complete_contract()
returns trigger
language plpgsql
as $$
begin
  -- The company's currency where none is named: read, never a default.
  if new.currency_code is null then
    select c.currency_code into new.currency_code from public.companies c where c.id = new.company_id;
  end if;

  if new.renewal = 'tacit' and new.renews_on is null and new.ends_on is not null then
    new.renews_on := new.ends_on + 1;
  end if;

  if tg_op = 'UPDATE' and new.state is distinct from old.state then
    if contracts.state_rank(old.state) = 5 then
      raise exception 'contracts_closed: contract % is %, which is final', old.number, old.state
        using errcode = '23514';
    end if;
    if new.state = 'cancelled' and old.state = 'active' then
      raise exception 'contracts_bad_state: contract % is running; it is terminated, not cancelled', old.number
        using errcode = '23514';
    end if;
    if new.state in ('expired', 'terminated') and contracts.state_rank(old.state) < 3 then
      raise exception 'contracts_bad_state: contract % was never signed; it is cancelled, not %', old.number, new.state
        using errcode = '23514';
    end if;
    if contracts.state_rank(new.state) < contracts.state_rank(old.state) then
      raise exception 'contracts_state_backwards: contract % is %, and does not go back to %', old.number, old.state, new.state
        using errcode = '23514';
    end if;
  end if;

  if new.state in ('signed', 'active') and new.signed_on is null then
    new.signed_on := current_date;
  end if;
  return new;
end;
$$;

comment on function contracts.complete_contract() is
  'Before a contract is written: takes the company''s currency when none is named, sets renews_on to the day after ends_on for a tacit renewal that has none, writes signed_on on a contract that reaches signed without one, and refuses a state that goes back (contracts_state_backwards), a move out of a final state (contracts_closed), a running contract cancelled or an unsigned one terminated (contracts_bad_state).';

create trigger contracts_contracts_complete
  before insert or update on contracts.contracts
  for each row execute function contracts.complete_contract();

-- No row of this schema names a contact merge_contacts() retired.
do $$
begin
  if to_regprocedure('public.refuse_merged_contacts_in(text)') is null then
    raise exception 'socle_too_old: the contracts module needs socle migration 20261019090000 (refuse_merged_contacts_in). Run ekwo migrate first.';
  end if;
  perform public.refuse_merged_contacts_in('contracts');
end;
$$;

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

create or replace function contracts.require(p_company_id uuid, p_capability text, p_what text)
returns void
language plpgsql
stable
as $$
begin
  if p_company_id is null
     or not public.module_is_enabled(p_company_id, 'contracts')
     or (not public.is_installer() and not public.module_enabled(p_company_id, 'contracts')) then
    raise exception 'contracts_module_not_enabled: the contracts module is not enabled on company %', p_company_id
      using errcode = '42501';
  end if;
  if not public.is_installer() and not public.has_capability(p_company_id, p_capability) then
    raise exception 'contracts_not_allowed: % needs %', p_what, p_capability
      using errcode = '42501';
  end if;
end;
$$;

comment on function contracts.require(uuid, text, text) is
  'Raises contracts_module_not_enabled when the module is off for the company or the caller is not a member of it, and contracts_not_allowed when the caller does not hold the capability. The first lines of every function of this module; the policies still decide every row.';

create or replace function contracts.step(p_from date, p_frequency contracts.frequency, p_steps integer)
returns date
language sql
immutable
as $$
  select (p_from + p_steps * case p_frequency
                               when 'weekly'    then interval '7 days'
                               when 'monthly'   then interval '1 month'
                               when 'quarterly' then interval '3 months'
                               when 'yearly'    then interval '1 year' end)::date;
$$;

comment on function contracts.step(date, contracts.frequency, integer) is
  'The day p_steps periods after p_from. Counted from the same first day every time, so the 31st of a month gives the last day of a shorter one and the 31st again after it.';

create or replace function contracts.render(p_text text, p_values jsonb)
returns text
language plpgsql
immutable
as $$
declare
  v_out text := p_text;
  v_key text;
  v_val text;
begin
  if p_text is null or p_values is null or jsonb_typeof(p_values) <> 'object' then
    return p_text;
  end if;
  for v_key, v_val in select e.key, e.value from jsonb_each_text(p_values) e loop
    v_out := replace(v_out, '{{' || v_key || '}}', coalesce(v_val, ''));
  end loop;
  return v_out;
end;
$$;

comment on function contracts.render(text, jsonb) is
  'The text with each {{key}} replaced by its value in p_values. A key with no value is left as it is written, so what is missing stays visible.';

create or replace function contracts.valid_indexation(p_indexation jsonb)
returns boolean
language plpgsql
immutable
as $$
begin
  if p_indexation is null then
    return true;
  end if;
  if jsonb_typeof(p_indexation) <> 'object' then
    return false;
  end if;
  if p_indexation ? 'next_on' then
    perform (p_indexation ->> 'next_on')::date;
  end if;
  if p_indexation ? 'base_on' then
    perform (p_indexation ->> 'base_on')::date;
  end if;
  return true;
exception when others then
  return false;
end;
$$;

comment on function contracts.valid_indexation(jsonb) is
  'Whether an indexation is a JSON object whose next_on and base_on, where given, are dates.';

alter table contracts.schedules
  add constraint contracts_schedules_indexation check (contracts.valid_indexation(indexation));

-- ---------------------------------------------------------------------------
-- Writing a contract and its schedules
-- ---------------------------------------------------------------------------

create or replace function contracts.upsert_contract(p_company_id uuid, p_number text, p_patch jsonb default '{}'::jsonb)
returns contracts.contracts
language plpgsql
as $$
declare
  v_fields constant text[] := array['contact_id', 'name', 'kind', 'direction', 'state', 'signed_on', 'starts_on',
                                    'ends_on', 'renews_on', 'renewal', 'notice_days', 'currency_code',
                                    'total_value', 'attachment_id', 'template_id', 'notes', 'analysis', 'attributes'];
  v_fixed  constant text[] := array['contact_id', 'direction', 'currency_code'];
  v_bad    text;
  v_row    contracts.contracts%rowtype;
  v_new    contracts.contracts%rowtype;
begin
  perform contracts.require(p_company_id, 'contracts.write', 'writing a contract');
  if nullif(btrim(p_number), '') is null then
    raise exception 'contracts_bad_contract: a contract has a number';
  end if;
  if p_patch is null or jsonb_typeof(p_patch) <> 'object' then
    raise exception 'contracts_bad_patch: the fields of a contract are given as a JSON object';
  end if;
  select k into v_bad from jsonb_object_keys(p_patch) k where k <> all (v_fields) order by k limit 1;
  if found then
    raise exception 'contracts_unknown_field: a contract has no field %; the fields are %', v_bad, array_to_string(v_fields, ', ');
  end if;

  select * into v_row from contracts.contracts c
   where c.company_id = p_company_id and c.number = btrim(p_number)
   for update;

  if not found then
    select k into v_bad from unnest(array['contact_id', 'name', 'kind', 'direction']) k
     where not (p_patch ? k) or p_patch ->> k is null order by k limit 1;
    if found then
      raise exception 'contracts_missing_field: a new contract needs %', v_bad;
    end if;
    v_new := jsonb_populate_record(null::contracts.contracts, p_patch);
    insert into contracts.contracts (company_id, contact_id, number, name, kind, direction, state, signed_on,
                                     starts_on, ends_on, renews_on, renewal, notice_days, currency_code,
                                     total_value, attachment_id, template_id, notes, analysis, attributes)
    values (p_company_id, v_new.contact_id, btrim(p_number), btrim(v_new.name), v_new.kind, v_new.direction,
            coalesce(v_new.state, 'draft'), v_new.signed_on, v_new.starts_on, v_new.ends_on, v_new.renews_on,
            coalesce(v_new.renewal, 'none'), v_new.notice_days, v_new.currency_code, v_new.total_value,
            v_new.attachment_id, v_new.template_id, v_new.notes,
            coalesce(v_new.analysis, '{}'::jsonb), coalesce(v_new.attributes, '{}'::jsonb))
    returning * into v_row;
    return v_row;
  end if;

  -- Once a document was issued, the party, the side and the currency are
  -- those of the documents: another one is another contract.
  select k into v_bad from unnest(v_fixed) k
   where p_patch ? k and (p_patch ->> k) is distinct from (to_jsonb(v_row) ->> k) order by k limit 1;
  if found and exists (select 1 from contracts.issues i where i.contract_id = v_row.id and i.company_id = p_company_id) then
    raise exception 'contracts_already_issued: contract % has issued documents, and its % does not change', v_row.number, v_bad;
  end if;

  v_new := jsonb_populate_record(v_row, p_patch);
  update contracts.contracts c
     set contact_id    = v_new.contact_id,
         name          = btrim(v_new.name),
         kind          = v_new.kind,
         direction     = v_new.direction,
         state         = v_new.state,
         signed_on     = v_new.signed_on,
         starts_on     = v_new.starts_on,
         ends_on       = v_new.ends_on,
         renews_on     = v_new.renews_on,
         renewal       = v_new.renewal,
         notice_days   = v_new.notice_days,
         currency_code = v_new.currency_code,
         total_value   = v_new.total_value,
         attachment_id = v_new.attachment_id,
         template_id   = v_new.template_id,
         notes         = v_new.notes,
         analysis      = v_new.analysis,
         attributes    = v_new.attributes
   where c.id = v_row.id
  returning * into v_row;
  return v_row;
end;
$$;

comment on function contracts.upsert_contract(uuid, text, jsonb) is
  'Creates the contract of that number in the company, or changes it: each field the patch names takes its value, every other one keeps its own. A new contract needs contact_id, name, kind and direction; its currency is the company''s unless currency_code is named. Once it has issued a document, its contact_id, direction and currency_code do not change (contracts_already_issued). An unknown key is refused by name, contracts_unknown_field. Needs contracts.write. Returns the contract.';

create or replace function contracts.upsert_schedule(
  p_company_id  uuid,
  p_contract_id uuid,
  p_schedule_id uuid default null,
  p_patch       jsonb default '{}'::jsonb
)
returns contracts.schedules
language plpgsql
as $$
declare
  v_fields   constant text[] := array['sequence', 'product_id', 'product_code', 'name', 'description', 'quantity',
                                      'unit_code', 'unit_price', 'tax_code', 'frequency', 'next_on', 'until',
                                      'indexation', 'auto_post'];
  v_bad      text;
  v_contract contracts.contracts%rowtype;
  v_product  public.products%rowtype;
  v_row      contracts.schedules%rowtype;
  v_new      contracts.schedules%rowtype;
  v_patch    jsonb := p_patch;
  v_tax      text;
begin
  perform contracts.require(p_company_id, 'contracts.write', 'writing a schedule');
  if v_patch is null or jsonb_typeof(v_patch) <> 'object' then
    raise exception 'contracts_bad_patch: the fields of a schedule are given as a JSON object';
  end if;
  select k into v_bad from jsonb_object_keys(v_patch) k where k <> all (v_fields) order by k limit 1;
  if found then
    raise exception 'contracts_unknown_field: a schedule has no field %; the fields are %', v_bad, array_to_string(v_fields, ', ');
  end if;
  select * into v_contract from contracts.contracts c where c.id = p_contract_id and c.company_id = p_company_id;
  if not found then
    raise exception 'contracts_unknown_contract: contract % is not a contract of company %', p_contract_id, p_company_id;
  end if;

  -- A product named by its code is the company's product of that code.
  if v_patch ? 'product_code' then
    if v_patch ->> 'product_code' is null then
      v_patch := v_patch - 'product_code' || jsonb_build_object('product_id', null);
    else
      select * into v_product from public.products p
       where p.company_id = p_company_id and p.code = v_patch ->> 'product_code';
      if not found then
        raise exception 'contracts_unknown_product: no product % in company %', v_patch ->> 'product_code', p_company_id;
      end if;
      v_patch := (v_patch - 'product_code') || jsonb_build_object('product_id', v_product.id);
    end if;
  elsif v_patch ->> 'product_id' is not null then
    select * into v_product from public.products p
     where p.id = (v_patch ->> 'product_id')::uuid and p.company_id = p_company_id;
    if not found then
      raise exception 'contracts_unknown_product: product % is not a product of company %', v_patch ->> 'product_id', p_company_id;
    end if;
  end if;

  if v_patch ->> 'tax_code' is not null
     and not exists (select 1 from public.taxes t where t.company_id = p_company_id and t.code = v_patch ->> 'tax_code') then
    raise exception 'contracts_unknown_tax: no tax of code % in company %', v_patch ->> 'tax_code', p_company_id;
  end if;

  if p_schedule_id is null then
    -- What the product says fills what the schedule left out, for the side
    -- of the contract: a pre-fill, never a constraint.
    if v_product.id is not null then
      if not (v_patch ? 'name') then
        v_patch := v_patch || jsonb_build_object('name', v_product.name);
      end if;
      if not (v_patch ? 'description') then
        v_patch := v_patch || jsonb_build_object('description', v_product.description);
      end if;
      if not (v_patch ? 'unit_code') then
        v_patch := v_patch || jsonb_build_object('unit_code', v_product.unit_code);
      end if;
      if not (v_patch ? 'unit_price') then
        v_patch := v_patch || jsonb_build_object('unit_price',
          case v_contract.direction when 'sale' then v_product.sale_price else v_product.purchase_price end);
      end if;
      if not (v_patch ? 'tax_code') then
        select t.code into v_tax from public.taxes t
         where t.company_id = p_company_id
           and t.id = case v_contract.direction when 'sale' then v_product.sale_tax_id else v_product.purchase_tax_id end;
        v_patch := v_patch || jsonb_build_object('tax_code', v_tax);
      end if;
    end if;
    select k into v_bad from unnest(array['name', 'unit_price', 'frequency', 'next_on']) k
     where v_patch ->> k is null order by k limit 1;
    if found then
      raise exception 'contracts_missing_field: a new schedule needs %', v_bad;
    end if;
    v_new := jsonb_populate_record(null::contracts.schedules, v_patch);
    insert into contracts.schedules (company_id, contract_id, sequence, product_id, name, description, quantity,
                                     unit_code, unit_price, tax_code, frequency, next_on, until, indexation, auto_post)
    values (p_company_id, p_contract_id, coalesce(v_new.sequence, 10), v_new.product_id, btrim(v_new.name),
            v_new.description, coalesce(v_new.quantity, 1), coalesce(v_new.unit_code, 'C62'), v_new.unit_price,
            v_new.tax_code, v_new.frequency, v_new.next_on, v_new.until, v_new.indexation,
            coalesce(v_new.auto_post, false))
    returning * into v_row;
    return v_row;
  end if;

  select * into v_row from contracts.schedules s
   where s.id = p_schedule_id and s.contract_id = p_contract_id and s.company_id = p_company_id
   for update;
  if not found then
    raise exception 'contracts_unknown_schedule: schedule % is not a schedule of contract %', p_schedule_id, v_contract.number;
  end if;
  v_new := jsonb_populate_record(v_row, v_patch);
  update contracts.schedules s
     set sequence    = v_new.sequence,
         product_id  = v_new.product_id,
         name        = btrim(v_new.name),
         description = v_new.description,
         quantity    = v_new.quantity,
         unit_code   = v_new.unit_code,
         unit_price  = v_new.unit_price,
         tax_code    = v_new.tax_code,
         frequency   = v_new.frequency,
         next_on     = v_new.next_on,
         until       = v_new.until,
         indexation  = v_new.indexation,
         auto_post   = v_new.auto_post
   where s.id = v_row.id
  returning * into v_row;
  return v_row;
end;
$$;

comment on function contracts.upsert_schedule(uuid, uuid, uuid, jsonb) is
  'Adds a schedule to a contract (p_schedule_id null) or changes one: each field the patch names takes its value. The fields are sequence, product_id or product_code, name, description, quantity, unit_code, unit_price, tax_code, frequency, next_on, until, indexation and auto_post. A new schedule from a product takes the product''s name, unit, price and tax for the side of the contract where the patch gives none; it needs a name, a unit_price, a frequency and a next_on. A product or a tax code the company does not have is refused by name. Needs contracts.write.';

create or replace function contracts.amend(
  p_company_id    uuid,
  p_contract_id   uuid,
  p_summary       text,
  p_effective_on  date,
  p_changes       jsonb default '{}'::jsonb,
  p_kind          contracts.amendment_kind default 'amendment',
  p_signed_on     date default null,
  p_attachment_id uuid default null
)
returns contracts.amendments
language plpgsql
as $$
declare
  v_contract contracts.contracts%rowtype;
  v_changes  jsonb := coalesce(p_changes, '{}'::jsonb);
  v_key      text;
  v_value    jsonb;
  v_row      contracts.amendments%rowtype;
begin
  perform contracts.require(p_company_id, 'contracts.write', 'amending a contract');
  if p_kind = 'renewal' then
    raise exception 'contracts_bad_amendment: a renewal is written by contracts.roll_forward(), on the day it falls';
  end if;
  if p_effective_on is null then
    raise exception 'contracts_bad_amendment: an amendment says from when it holds';
  end if;
  if nullif(btrim(p_summary), '') is null then
    raise exception 'contracts_bad_amendment: an amendment says what changes, in words';
  end if;
  if jsonb_typeof(v_changes) <> 'object' then
    raise exception 'contracts_bad_patch: the changes of an amendment are given as a JSON object';
  end if;
  if p_kind = 'version' and v_changes <> '{}'::jsonb then
    raise exception 'contracts_bad_amendment: a version is another text of the contract and changes no field; an amendment does';
  end if;
  select * into v_contract from contracts.contracts c
   where c.id = p_contract_id and c.company_id = p_company_id
   for update;
  if not found then
    raise exception 'contracts_unknown_contract: contract % is not a contract of company %', p_contract_id, p_company_id;
  end if;

  -- What it changes is applied, with the refusals of the two writers.
  if v_changes ? 'schedules' then
    if jsonb_typeof(v_changes -> 'schedules') <> 'object' then
      raise exception 'contracts_bad_patch: the schedules an amendment changes are an object, by schedule id';
    end if;
    for v_key, v_value in select e.key, e.value from jsonb_each(v_changes -> 'schedules') e loop
      perform contracts.upsert_schedule(p_company_id, p_contract_id, v_key::uuid, v_value);
    end loop;
  end if;
  if (v_changes - 'schedules') <> '{}'::jsonb then
    perform contracts.upsert_contract(p_company_id, v_contract.number, v_changes - 'schedules');
  end if;

  insert into contracts.amendments (company_id, contract_id, number, kind, summary, changes, effective_on,
                                    signed_on, attachment_id)
  values (p_company_id, p_contract_id,
          coalesce((select max(a.number) from contracts.amendments a
                     where a.contract_id = p_contract_id and a.company_id = p_company_id), 0) + 1,
          p_kind, btrim(p_summary), v_changes, p_effective_on, p_signed_on, p_attachment_id)
  returning * into v_row;
  return v_row;
end;
$$;

comment on function contracts.amend(uuid, uuid, text, date, jsonb, contracts.amendment_kind, date, uuid) is
  'Records what changes in a contract and from when, numbered next in its history, with the signed file. An amendment applies its changes as it is recorded: the fields of the contract through contracts.upsert_contract(), and under "schedules", by id, the fields of each schedule through contracts.upsert_schedule() — with their refusals. A version records another text with its file and changes no field. A renewal is refused: contracts.roll_forward() writes it. Needs contracts.write.';

-- ---------------------------------------------------------------------------
-- Time passing: renewals, expiries, issues
-- ---------------------------------------------------------------------------

create or replace function contracts.roll_forward(p_company_id uuid, p_on_date date)
returns table (contract_id uuid, number text, change text, ends_on date)
language plpgsql
as $$
declare
  v_c     contracts.contracts%rowtype;
  v_start date;
  v_from  date;
  v_end   date;
  v_guard integer;
begin
  perform contracts.require(p_company_id, 'contracts.write', 'moving contracts to a day');
  if p_on_date is null then
    raise exception 'contracts_bad_date: a day is given';
  end if;

  for v_c in
    select * from contracts.contracts c
     where c.company_id = p_company_id and c.state in ('signed', 'active')
     order by c.number
     for update
  loop
    if v_c.state = 'signed' and v_c.starts_on is not null and v_c.starts_on <= p_on_date then
      update contracts.contracts c set state = 'active' where c.id = v_c.id returning * into v_c;
      contract_id := v_c.id; number := v_c.number; change := 'activated'; ends_on := v_c.ends_on;
      return next;
    end if;
    continue when v_c.state <> 'active' or v_c.ends_on is null or v_c.ends_on >= p_on_date;

    if v_c.renewal = 'none' then
      update contracts.contracts c set state = 'expired' where c.id = v_c.id;
      contract_id := v_c.id; number := v_c.number; change := 'expired'; ends_on := v_c.ends_on;
      return next;
      continue;
    end if;

    -- Tacit: one more term of the length of the one that ends, as many times
    -- as the day asks. The term that ends started at the last renewal, or at
    -- the start of the contract.
    v_guard := 0;
    while v_c.ends_on < p_on_date loop
      v_guard := v_guard + 1;
      if v_guard > 500 then
        raise exception 'contracts_too_many_renewals: contract % would renew more than 500 times to reach %', v_c.number, p_on_date;
      end if;
      select coalesce(max(a.effective_on), v_c.starts_on) into v_from
        from contracts.amendments a
       where a.contract_id = v_c.id and a.company_id = p_company_id and a.kind = 'renewal';
      v_start := v_c.ends_on + 1;
      v_end   := (v_start + age(v_start::timestamp, v_from::timestamp))::date - 1;
      update contracts.contracts c set ends_on = v_end, renews_on = v_end + 1
       where c.id = v_c.id returning * into v_c;
      insert into contracts.amendments (company_id, contract_id, number, kind, summary, changes, effective_on, created_by)
      values (p_company_id, v_c.id,
              coalesce((select max(a.number) from contracts.amendments a
                         where a.contract_id = v_c.id and a.company_id = p_company_id), 0) + 1,
              'renewal', 'Tacit renewal',
              jsonb_build_object('ends_on', v_end, 'renews_on', v_end + 1), v_start, null);
      contract_id := v_c.id; number := v_c.number; change := 'renewed'; ends_on := v_end;
      return next;
    end loop;
  end loop;
end;
$$;

comment on function contracts.roll_forward(uuid, date) is
  'Brings the contracts of a company to a day: a signed contract whose start has come is active; an active one whose last day is past expires when it does not renew, and renews tacitly otherwise — one term of the length of the term that ends, recorded as a renewal amendment, as many times as the day asks. A contract given notice is terminated by its user beforehand and is not touched. Returns one row per change. Needs contracts.write.';

create or replace function contracts.issue_due(p_company_id uuid, p_on_date date)
returns table (
  contract_id     uuid,
  contract_number text,
  schedule_id     uuid,
  document_id     uuid,
  period_start    date,
  period_end      date,
  posted          boolean
)
language plpgsql
as $$
declare
  v_s        contracts.schedules%rowtype;
  v_c        contracts.contracts%rowtype;
  v_anchor   date;
  v_k        integer;
  v_start    date;
  v_next     date;
  v_end      date;
  v_tax      uuid;
  v_doc      uuid;
  v_guard    integer;
begin
  perform contracts.require(p_company_id, 'contracts.issue', 'issuing the documents of the contracts');
  perform contracts.require(p_company_id, 'contracts.write', 'moving a schedule to its next period');
  if not public.is_installer() and not public.has_capability(p_company_id, 'documents.write') then
    raise exception 'contracts_not_allowed: issuing the documents of the contracts writes documents, which needs documents.write'
      using errcode = '42501';
  end if;
  if p_on_date is null then
    raise exception 'contracts_bad_date: a day is given';
  end if;

  -- Renewals and expiries first: a contract renewed today still issues.
  perform 1 from contracts.roll_forward(p_company_id, p_on_date);

  for v_s in
    select s.* from contracts.schedules s
      join contracts.contracts c on c.id = s.contract_id and c.company_id = s.company_id
     where s.company_id = p_company_id
       and c.state in ('signed', 'active')
       and s.next_on <= p_on_date
       and (s.until is null or s.next_on <= s.until)
       and (c.ends_on is null or s.next_on <= c.ends_on)
     order by c.number, s.sequence, s.id
     for update of s
  loop
    select * into v_c from contracts.contracts c where c.id = v_s.contract_id;
    if v_s.auto_post and not public.is_installer() and not public.has_capability(p_company_id, 'documents.post') then
      raise exception 'contracts_not_allowed: schedule % of contract % books what it issues, which needs documents.post', v_s.name, v_c.number
        using errcode = '42501';
    end if;
    v_tax := null;
    if v_s.tax_code is not null then
      select t.id into v_tax from public.taxes t where t.company_id = p_company_id and t.code = v_s.tax_code;
      if not found then
        raise exception 'contracts_unknown_tax: schedule % of contract % names tax %, which company % does not have',
          v_s.name, v_c.number, v_s.tax_code, p_company_id;
      end if;
    end if;

    -- The periods are counted from the first one this schedule issued, so a
    -- month-end stays a month-end. A next_on moved by hand off that count
    -- starts a new count.
    select min(i.period_start) into v_anchor from contracts.issues i
     where i.schedule_id = v_s.id and i.company_id = p_company_id;
    v_anchor := coalesce(v_anchor, v_s.next_on);
    v_k := 0;
    while contracts.step(v_anchor, v_s.frequency, v_k) < v_s.next_on and v_k < 100000 loop
      v_k := v_k + 1;
    end loop;
    if contracts.step(v_anchor, v_s.frequency, v_k) <> v_s.next_on then
      v_anchor := v_s.next_on;
      v_k := 0;
    end if;

    v_start := v_s.next_on;
    v_guard := 0;
    loop
      v_guard := v_guard + 1;
      if v_guard > 1000 then
        raise exception 'contracts_too_many_periods: schedule % of contract % has more than 1000 periods to issue before %', v_s.name, v_c.number, p_on_date;
      end if;
      v_next := contracts.step(v_anchor, v_s.frequency, v_k + 1);
      v_end  := least(v_next - 1, coalesce(v_c.ends_on, v_next - 1));

      insert into public.documents (company_id, doc_type, contact_id, document_date, currency_code,
                                    contract_reference, client_ref)
      values (p_company_id,
              case v_c.direction when 'sale' then 'sale_invoice'::public.doc_type else 'purchase_invoice'::public.doc_type end,
              v_c.contact_id, v_start, v_c.currency_code, v_c.number,
              'contracts:' || v_s.id || ':' || to_char(v_start, 'YYYY-MM-DD'))
      returning id into v_doc;

      insert into public.document_lines (document_id, company_id, sequence, line_type, name, description, quantity,
                                         unit_code, unit_price, tax_id, product_id)
      values (v_doc, p_company_id, 10, 'product', v_s.name, v_s.description, v_s.quantity,
              v_s.unit_code, v_s.unit_price, v_tax, v_s.product_id);

      insert into contracts.issues (company_id, contract_id, schedule_id, document_id, period_start, period_end)
      values (p_company_id, v_c.id, v_s.id, v_doc, v_start, v_end);

      if v_s.auto_post then
        perform public.post_document(v_doc);
      end if;

      contract_id := v_c.id; contract_number := v_c.number; schedule_id := v_s.id; document_id := v_doc;
      period_start := v_start; period_end := v_end; posted := v_s.auto_post;
      return next;

      v_k := v_k + 1;
      v_start := v_next;
      exit when v_start > p_on_date
             or (v_s.until is not null and v_start > v_s.until)
             or (v_c.ends_on is not null and v_start > v_c.ends_on);
    end loop;

    update contracts.schedules s set next_on = v_start where s.id = v_s.id;
  end loop;
end;
$$;

comment on function contracts.issue_due(uuid, date) is
  'Issues every period that has come: for each schedule of a signed or active contract whose next_on is on or before the day — and before its until and the contract''s end — one draft document of the socle per period, a sales invoice on a sale and a purchase invoice on a purchase, dated the first day of the period, to the contract''s party, in its currency, contract_reference set to its number, with one line of the schedule; recorded in contracts.issues with the period it covers, and next_on moved to the period after. Renewals and expiries of contracts.roll_forward() come first. Idempotent per schedule and period: the document carries client_ref contracts:<schedule>:<first day>, which the socle refuses twice. A schedule with auto_post has its documents booked by post_document(). Needs contracts.issue, contracts.write and documents.write — documents.post for auto_post — each refused by name. Returns one row per document.';

-- ---------------------------------------------------------------------------
-- Templates into contracts
-- ---------------------------------------------------------------------------

create or replace function contracts.from_template(
  p_company_id  uuid,
  p_template_id uuid,
  p_contact_id  uuid,
  p_number      text,
  p_direction   contracts.direction,
  p_kind        contracts.contract_kind,
  p_starts_on   date,
  p_values      jsonb default '{}'::jsonb,
  p_name        text default null
)
returns jsonb
language plpgsql
as $$
declare
  v_t        contracts.templates%rowtype;
  v_values   jsonb := coalesce(p_values, '{}'::jsonb);
  v_var      jsonb;
  v_missing  text;
  v_contract contracts.contracts%rowtype;
  v_line     jsonb;
  v_out      jsonb := '[]'::jsonb;
begin
  perform contracts.require(p_company_id, 'contracts.write', 'making a contract from a template');
  select * into v_t from contracts.templates t where t.id = p_template_id and t.company_id = p_company_id;
  if not found then
    raise exception 'contracts_unknown_template: template % is not a template of company %', p_template_id, p_company_id;
  end if;
  if not v_t.active then
    raise exception 'contracts_template_inactive: template % is no longer used', v_t.name;
  end if;
  if jsonb_typeof(v_values) <> 'object' then
    raise exception 'contracts_bad_patch: the values of the variables are given as a JSON object';
  end if;
  if exists (select 1 from contracts.contracts c where c.company_id = p_company_id and c.number = btrim(p_number)) then
    raise exception 'contracts_number_taken: company % already has a contract numbered %', p_company_id, p_number;
  end if;

  -- A default the template gives fills an empty value; a required variable
  -- still empty is refused by name.
  for v_var in select e from jsonb_array_elements(v_t.variables) e loop
    continue when v_var ->> 'key' is null;
    if nullif(btrim(v_values ->> (v_var ->> 'key')), '') is null and v_var ->> 'default_value' is not null then
      v_values := v_values || jsonb_build_object(v_var ->> 'key', v_var ->> 'default_value');
    end if;
    if coalesce((v_var ->> 'required')::boolean, false)
       and nullif(btrim(v_values ->> (v_var ->> 'key')), '') is null then
      v_missing := coalesce(v_missing || ', ', '') || (v_var ->> 'key');
    end if;
  end loop;
  if v_missing is not null then
    raise exception 'contracts_missing_variable: template % needs %', v_t.name, v_missing;
  end if;

  v_contract := contracts.upsert_contract(p_company_id, p_number, jsonb_build_object(
    'contact_id', p_contact_id,
    'name', coalesce(nullif(btrim(p_name), ''), v_t.name),
    'kind', p_kind,
    'direction', p_direction,
    'starts_on', p_starts_on,
    'template_id', v_t.id,
    'attributes', jsonb_build_object('variables', v_values)));

  for v_line in select e from jsonb_array_elements(v_t.schedule) e loop
    v_out := v_out || to_jsonb(contracts.upsert_schedule(p_company_id, v_contract.id, null,
                                 jsonb_build_object('next_on', p_starts_on) || v_line));
  end loop;

  return jsonb_build_object(
    'contract', to_jsonb(v_contract),
    'schedules', v_out,
    'format', v_t.format,
    'html', contracts.render(v_t.html, v_values),
    'attachment_id', v_t.attachment_id,
    'variables', v_values);
end;
$$;

comment on function contracts.from_template(uuid, uuid, uuid, text, contracts.direction, contracts.contract_kind, date, jsonb, text) is
  'Makes a draft contract of a template: the number, party, side and kind given, starting on p_starts_on, named after the template unless p_name is given, the values of the variables kept in attributes.variables — a default of the template filling an empty one, a required one still empty refused by name, contracts_missing_variable — and the template schedule copied, each line starting on p_starts_on. Answers the contract, its schedules, and the clauses: the html with the values in place, or the docx attachment to fill. Needs contracts.write.';

-- ---------------------------------------------------------------------------
-- Reading
-- ---------------------------------------------------------------------------

create view contracts.deadlines
  with (security_invoker = true) as
  select c.company_id, c.id as contract_id, c.number as contract_number, c.name as contract_name,
         c.direction, c.contact_id, null::uuid as schedule_id, 'notice'::text as kind,
         coalesce(c.renews_on, c.ends_on + 1) - c.notice_days as due_on
    from contracts.contracts c
   where c.state in ('signed', 'active') and c.notice_days is not null
     and coalesce(c.renews_on, c.ends_on + 1) is not null
  union all
  select c.company_id, c.id, c.number, c.name, c.direction, c.contact_id, null, 'renewal', c.renews_on
    from contracts.contracts c
   where c.state in ('signed', 'active') and c.renews_on is not null
  union all
  select c.company_id, c.id, c.number, c.name, c.direction, c.contact_id, null, 'end', c.ends_on
    from contracts.contracts c
   where c.state in ('signed', 'active') and c.ends_on is not null
  union all
  select s.company_id, c.id, c.number, c.name, c.direction, c.contact_id, s.id, 'next_issue', s.next_on
    from contracts.schedules s
    join contracts.contracts c on c.id = s.contract_id and c.company_id = s.company_id
   where c.state in ('signed', 'active')
     and (s.until is null or s.next_on <= s.until)
     and (c.ends_on is null or s.next_on <= c.ends_on)
  union all
  select s.company_id, c.id, c.number, c.name, c.direction, c.contact_id, s.id, 'indexation',
         (s.indexation ->> 'next_on')::date
    from contracts.schedules s
    join contracts.contracts c on c.id = s.contract_id and c.company_id = s.company_id
   where c.state in ('signed', 'active') and s.indexation ? 'next_on';

comment on view contracts.deadlines is
  'Every date a running contract — signed or active — asks somebody to act on, one row each: notice (the last day notice can be given: notice_days before the next term, or before the day after the end where it does not renew), renewal, end, next_issue (the first day of the next period a schedule issues) and indexation (the day a schedule''s indexation is due). Read under the policies of the contracts and schedules it comes from.';

create or replace function contracts.list_contracts(
  p_company_id uuid,
  p_state      contracts.contract_state default null,
  p_direction  contracts.direction default null,
  p_contact_id uuid default null,
  p_query      text default null,
  p_limit      integer default 50
)
returns table (
  id            uuid,
  number        text,
  name          text,
  kind          contracts.contract_kind,
  direction     contracts.direction,
  state         contracts.contract_state,
  contact_id    uuid,
  contact_name  text,
  starts_on     date,
  ends_on       date,
  renewal       contracts.renewal,
  currency_code char(3),
  total_value   numeric,
  next_deadline date,
  next_kind     text
)
language plpgsql
stable
as $$
begin
  perform contracts.require(p_company_id, 'contracts.read', 'reading the contracts');
  return query
  select c.id, c.number, c.name, c.kind, c.direction, c.state, c.contact_id, k.name, c.starts_on, c.ends_on,
         c.renewal, c.currency_code, c.total_value, d.due_on, d.kind
    from contracts.contracts c
    join public.contacts k on k.id = c.contact_id and k.company_id = c.company_id
    left join lateral (select x.due_on, x.kind from contracts.deadlines x
                        where x.contract_id = c.id order by x.due_on, x.kind limit 1) d on true
   where c.company_id = p_company_id
     and (p_state is null or c.state = p_state)
     and (p_direction is null or c.direction = p_direction)
     and (p_contact_id is null or c.contact_id = p_contact_id)
     and (p_query is null or c.number ilike '%' || p_query || '%' or c.name ilike '%' || p_query || '%'
          or k.name ilike '%' || p_query || '%')
   order by c.number
   limit greatest(coalesce(p_limit, 50), 0);
end;
$$;

comment on function contracts.list_contracts(uuid, contracts.contract_state, contracts.direction, uuid, text, integer) is
  'The contracts of a company, filtered by state, side, party, or a text found in the number, the name or the party''s name — every filter optional — each with its party''s name and its nearest deadline. In the order of their numbers, at most p_limit rows (50). Needs contracts.read.';

create or replace function contracts.card_of(p_company_id uuid, p_contract_id uuid)
returns jsonb
language plpgsql
stable
as $$
declare
  v_c   contracts.contracts%rowtype;
  v_out jsonb;
begin
  perform contracts.require(p_company_id, 'contracts.read', 'reading a contract');
  select * into v_c from contracts.contracts c where c.id = p_contract_id and c.company_id = p_company_id;
  if not found then
    raise exception 'contracts_unknown_contract: contract % is not a contract of company %', p_contract_id, p_company_id;
  end if;
  select jsonb_build_object(
    'contract', to_jsonb(v_c),
    'contact', (select jsonb_build_object('id', k.id, 'name', k.name, 'contact_type', k.contact_type,
                                          'email', k.email, 'country', k.country, 'vat_number', k.vat_number)
                  from public.contacts k where k.id = v_c.contact_id and k.company_id = p_company_id),
    'file', (select jsonb_build_object('id', a.id, 'file_name', a.file_name, 'mime_type', a.mime_type,
                                       'checksum', a.checksum, 'storage_path', a.storage_path)
               from public.attachments a where a.id = v_c.attachment_id and a.company_id = p_company_id),
    'schedules', coalesce((select jsonb_agg(to_jsonb(s) order by s.sequence, s.created_at)
                             from contracts.schedules s
                            where s.contract_id = v_c.id and s.company_id = p_company_id), '[]'::jsonb),
    'amendments', coalesce((select jsonb_agg(to_jsonb(a) order by a.number)
                              from contracts.amendments a
                             where a.contract_id = v_c.id and a.company_id = p_company_id), '[]'::jsonb),
    'issues', coalesce((select jsonb_agg(jsonb_build_object('id', i.id, 'schedule_id', i.schedule_id,
                                                            'document_id', i.document_id,
                                                            'period_start', i.period_start, 'period_end', i.period_end,
                                                            'number', d.number, 'state', d.state,
                                                            'amount_total', d.amount_total,
                                                            'currency_code', d.currency_code)
                                         order by i.period_start desc, i.created_at desc)
                          from (select * from contracts.issues i
                                 where i.contract_id = v_c.id and i.company_id = p_company_id
                                 order by i.period_start desc, i.created_at desc limit 24) i
                          left join public.documents d on d.id = i.document_id and d.company_id = i.company_id),
                       '[]'::jsonb),
    'deadlines', coalesce((select jsonb_agg(jsonb_build_object('kind', x.kind, 'due_on', x.due_on,
                                                               'schedule_id', x.schedule_id)
                                            order by x.due_on, x.kind)
                             from contracts.deadlines x where x.contract_id = v_c.id), '[]'::jsonb)
  ) into v_out;
  return v_out;
end;
$$;

comment on function contracts.card_of(uuid, uuid) is
  'Everything on one contract, as one JSON object: the contract, its party, its signed file with its checksum, its schedules, its history of versions, amendments and renewals, the 24 latest documents it issued with their number, state and total, and its deadlines. Needs contracts.read.';

create or replace function contracts.list_templates(p_company_id uuid, p_include_inactive boolean default false)
returns setof contracts.templates
language plpgsql
stable
as $$
begin
  perform contracts.require(p_company_id, 'contracts.read', 'reading the templates');
  return query
  select * from contracts.templates t
   where t.company_id = p_company_id and (p_include_inactive or t.active)
   order by t.category nulls last, t.name, t.id;
end;
$$;

comment on function contracts.list_templates(uuid, boolean) is
  'The templates of a company, by category and name — the active ones unless p_include_inactive. Needs contracts.read.';

-- ---------------------------------------------------------------------------
-- The conventions the socle looks a module up by
-- ---------------------------------------------------------------------------

-- No `contracts.can_disable()`: turning the module off hides the rows and
-- stops the issues; the documents already issued are the socle's and stay.

create or replace function contracts.archive_tables()
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
    ('templates'::text,  'exported'::text, null::text, null::text, null::text, 1),
    ('contracts',        'exported',       null,       null,       null,       2),
    ('schedules',        'exported',       null,       null,       null,       3),
    ('amendments',       'exported',       null,       null,       null,       4),
    ('issues',           'exported',       null,       null,       null,       5);
$$;

comment on function contracts.archive_tables() is
  'What an archive of one company does with each table of this module: all five travel — what a company agreed is part of its books. Read by `public.company_archive_tables()`.';

-- ---------------------------------------------------------------------------
-- Capabilities
--
-- Reading goes to whoever reads the books, client included. Writing is the
-- module's own word. Issuing is a third one: it writes documents of the
-- socle, so a member may keep the contracts without invoicing from them.
-- ---------------------------------------------------------------------------

insert into public.capabilities (code, area, description) values
  ('contracts.read',  'contracts', 'Read the contracts of a company, their schedules, amendments, templates, the documents they issued and their deadlines.'),
  ('contracts.write', 'contracts', 'Create and change contracts, schedules, amendments and templates.'),
  ('contracts.issue', 'contracts', 'Issue the documents the schedules of the contracts say are due.')
on conflict (code) do update set area = excluded.area, description = excluded.description;

insert into public.role_capabilities (role, capability) values
  ('viewer'::public.member_role,     'contracts.read'),
  ('accountant'::public.member_role, 'contracts.read'),
  ('accountant'::public.member_role, 'contracts.write'),
  ('accountant'::public.member_role, 'contracts.issue'),
  ('owner'::public.member_role,      'contracts.read'),
  ('owner'::public.member_role,      'contracts.write'),
  ('owner'::public.member_role,      'contracts.issue')
on conflict do nothing;

-- The client preset holds what a viewer holds, read from the catalogue so the
-- file applies on a socle older than the preset.
insert into public.role_capabilities (role, capability)
select e.enumlabel::text::public.member_role, 'contracts.read'
  from pg_catalog.pg_enum e
  join pg_catalog.pg_type t on t.oid = e.enumtypid
  join pg_catalog.pg_namespace n on n.oid = t.typnamespace
 where n.nspname = 'public' and t.typname = 'member_role' and e.enumlabel = 'client'
on conflict do nothing;

-- ---------------------------------------------------------------------------
-- Row level security
-- ---------------------------------------------------------------------------

alter table contracts.templates  enable row level security;
alter table contracts.contracts  enable row level security;
alter table contracts.schedules  enable row level security;
alter table contracts.issues     enable row level security;
alter table contracts.amendments enable row level security;

do $$
declare
  v_table text;
begin
  foreach v_table in array array['templates', 'contracts', 'schedules', 'issues', 'amendments'] loop
    execute format(
      'create policy %I on contracts.%I for select using (public.module_enabled(company_id, %L) and public.has_capability(company_id, %L))',
      'contracts_' || v_table || '_select', v_table, 'contracts', 'contracts.read');
    -- An issue is written by whoever issues; everything else by whoever writes.
    execute format(
      'create policy %I on contracts.%I for all using (public.module_enabled(company_id, %L) and public.has_capability(company_id, %L)) '
      'with check (public.module_enabled(company_id, %L) and public.has_capability(company_id, %L))',
      'contracts_' || v_table || '_write', v_table, 'contracts',
      case v_table when 'issues' then 'contracts.issue' else 'contracts.write' end, 'contracts',
      case v_table when 'issues' then 'contracts.issue' else 'contracts.write' end);
  end loop;
end;
$$;

-- ---------------------------------------------------------------------------
-- Privileges, by name
-- ---------------------------------------------------------------------------

grant usage on schema contracts to anon, authenticated, service_role;

grant select, insert, update, delete on table
  contracts.templates,
  contracts.contracts,
  contracts.schedules,
  contracts.issues,
  contracts.amendments
to authenticated, service_role;

grant select on contracts.deadlines to authenticated, service_role;

revoke execute on function contracts.state_rank(contracts.contract_state) from public, anon;
revoke execute on function contracts.require(uuid, text, text) from public, anon;
revoke execute on function contracts.step(date, contracts.frequency, integer) from public, anon;
revoke execute on function contracts.render(text, jsonb) from public, anon;
revoke execute on function contracts.valid_indexation(jsonb) from public, anon;
revoke execute on function contracts.upsert_contract(uuid, text, jsonb) from public, anon;
revoke execute on function contracts.upsert_schedule(uuid, uuid, uuid, jsonb) from public, anon;
revoke execute on function contracts.amend(uuid, uuid, text, date, jsonb, contracts.amendment_kind, date, uuid) from public, anon;
revoke execute on function contracts.roll_forward(uuid, date) from public, anon;
revoke execute on function contracts.issue_due(uuid, date) from public, anon;
revoke execute on function contracts.from_template(uuid, uuid, uuid, text, contracts.direction, contracts.contract_kind, date, jsonb, text) from public, anon;
revoke execute on function contracts.list_contracts(uuid, contracts.contract_state, contracts.direction, uuid, text, integer) from public, anon;
revoke execute on function contracts.card_of(uuid, uuid) from public, anon;
revoke execute on function contracts.list_templates(uuid, boolean) from public, anon;
revoke execute on function contracts.archive_tables() from public, anon;

grant execute on function contracts.state_rank(contracts.contract_state) to authenticated, service_role;
grant execute on function contracts.require(uuid, text, text) to authenticated, service_role;
grant execute on function contracts.step(date, contracts.frequency, integer) to authenticated, service_role;
grant execute on function contracts.render(text, jsonb) to authenticated, service_role;
grant execute on function contracts.valid_indexation(jsonb) to authenticated, service_role;
grant execute on function contracts.upsert_contract(uuid, text, jsonb) to authenticated, service_role;
grant execute on function contracts.upsert_schedule(uuid, uuid, uuid, jsonb) to authenticated, service_role;
grant execute on function contracts.amend(uuid, uuid, text, date, jsonb, contracts.amendment_kind, date, uuid) to authenticated, service_role;
grant execute on function contracts.roll_forward(uuid, date) to authenticated, service_role;
grant execute on function contracts.issue_due(uuid, date) to authenticated, service_role;
grant execute on function contracts.from_template(uuid, uuid, uuid, text, contracts.direction, contracts.contract_kind, date, jsonb, text) to authenticated, service_role;
grant execute on function contracts.list_contracts(uuid, contracts.contract_state, contracts.direction, uuid, text, integer) to authenticated, service_role;
grant execute on function contracts.card_of(uuid, uuid) to authenticated, service_role;
grant execute on function contracts.list_templates(uuid, boolean) to authenticated, service_role;
grant execute on function contracts.archive_tables() to authenticated, service_role;

-- The trigger bodies are fired by their tables and called by nobody.
revoke execute on function contracts.guard_attachment() from public, anon, authenticated, service_role;
revoke execute on function contracts.complete_contract() from public, anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- The registry row
-- ---------------------------------------------------------------------------

insert into public.modules (code, name, description, schema_name, version, status, requires_socle_min)
values (
  'contracts',
  'Contracts',
  'What a company agreed with another party, kept beside the books on the same contacts: dates, renewal, notice, value, the signed file, amendments and templates, and schedules that issue draft sales or purchase invoices when their periods come. Knows no country, and never writes the ledger itself.',
  'contracts',
  '0.1.0',
  'available',
  '20261019150000'
)
on conflict (code) do update set
  name               = excluded.name,
  description        = excluded.description,
  schema_name        = excluded.schema_name,
  version            = excluded.version,
  status             = excluded.status,
  requires_socle_min = excluded.requires_socle_min;
