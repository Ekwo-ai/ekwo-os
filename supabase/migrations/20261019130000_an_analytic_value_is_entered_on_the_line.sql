-- Ekwo OS — an analytic value is entered on the line, and read from the ledger.
--
-- `20260911120800` created the analytic plan — `analytic_axes`,
-- `analytic_values` and `entry_line_analytics`, the split of a ledger line in
-- percent — and nothing filled it or read it. This file wires it, as decision
-- 0075 records:
--
--   * `document_line_analytics` is the split of a document line, the same
--     shape and checks as the split of a ledger line. The person keys the
--     value where they know what a cost or a revenue is for: on the line of
--     the invoice.
--   * `post_document()` groups the lines of a document by account, tax *and
--     split*, and copies the split of each group onto the ledger line it
--     writes. From then on the ledger line is the one truth; no report reads
--     the document split again. `cancel_document()` gives the credit note the
--     split of the invoice it cancels.
--   * Only a result account carries a split: `accounts.internal_group` is
--     `income` or `expense`, which every chart of every pack says through the
--     account type of each account. Anything else is refused by name,
--     `analytic_not_on_result_account`. No account code is read.
--   * On one axis the shares of a line add up to at most 100
--     (`analytic_split_over_100`); less leaves the rest unassigned. The
--     `amount` of a share is the database's, derived from the line.
--   * A product, and a contact, may carry a default value. It pre-fills a
--     line and never constrains it, as a product's account and price do.
--
-- The report that reads it, `analytic_report()`, is the next file.

-- ---------------------------------------------------------------------------
-- 1. The split of a document line
-- ---------------------------------------------------------------------------

create table document_line_analytics (
  id                uuid primary key default gen_random_uuid(),
  company_id        uuid not null references companies(id) on delete cascade,
  -- Every reference holds the company (decision 0065): a line or a value of
  -- another company is refused by the same key as one of nobody.
  document_line_id  uuid not null,
  analytic_value_id uuid not null,
  percentage        numeric(7, 3) not null default 100,
  -- Derived: the share of the line's untaxed amount, in the document's
  -- currency. Written by `document_line_analytics_refresh()`, never by hand.
  amount            numeric(16, 2),
  created_at        timestamptz not null default now(),
  unique (document_line_id, analytic_value_id, company_id),
  constraint document_line_analytics_percentage check (percentage > 0 and percentage <= 100),
  foreign key (document_line_id, company_id) references document_lines(id, company_id) on delete cascade,
  foreign key (analytic_value_id, company_id) references analytic_values(id, company_id) on delete restrict
);

comment on table document_line_analytics is
  'Analytic split of a document line, one row per value, share in percent. Copied onto the ledger line by post_document(); after posting the ledger split is the one read.';
comment on column document_line_analytics.amount is
  'The share of the line''s untaxed amount in the document''s currency, derived by the database. The shares of one axis are rounded in the order of their codes, so a whole split adds up to its line.';
comment on column entry_line_analytics.amount is
  'The share of the line''s balance (debit minus credit) in the company''s currency, derived by the database. The shares of one axis are rounded in the order of their codes, so a whole split adds up to its line.';

create index document_line_analytics_analytic_value_company_idx on document_line_analytics (analytic_value_id, company_id);
create index document_line_analytics_company_idx on document_line_analytics (company_id);
create index document_line_analytics_document_line_company_idx on document_line_analytics (document_line_id, company_id);

alter table document_line_analytics enable row level security;

-- The split is part of the line, so it is read and written with the lines:
-- `documents.read` and `documents.write`, in the form every policy has had
-- since `a_policy_asks_once`.
create policy document_line_analytics_select on document_line_analytics
  for select using (company_id = any ((select companies_with_capability('documents.read'))::uuid[]));
create policy document_line_analytics_write on document_line_analytics
  for all using (company_id = any ((select companies_with_capability('documents.write'))::uuid[]))
  with check (company_id = any ((select companies_with_capability('documents.write'))::uuid[]));

grant select, insert, update, delete on table document_line_analytics to authenticated, service_role;

-- Loaded after the lines and the values it points at.
insert into company_archive_registry (table_name, disposition, load_order, via_column, via_table, reason) values
  ('document_line_analytics', 'exported', 66, null, null,
   'The analytic split of each document line, as it was keyed. The ledger carries its own copy from posting.')
on conflict (table_schema, table_name) do nothing;

-- ---------------------------------------------------------------------------
-- 2. A default value on a product and on a contact
-- ---------------------------------------------------------------------------

alter table products
  add column if not exists analytic_value_id uuid;
alter table products
  add constraint products_analytic_value_company_fkey
    foreign key (analytic_value_id, company_id) references analytic_values(id, company_id);
create index products_analytic_value_company_idx on products (analytic_value_id, company_id);

comment on column products.analytic_value_id is
  'The analytic value a line filled in from this product starts with, at 100 %. Pre-fills the line, never constrains it.';

alter table contacts
  add column if not exists analytic_value_id uuid;
alter table contacts
  add constraint contacts_analytic_value_company_fkey
    foreign key (analytic_value_id, company_id) references analytic_values(id, company_id);
create index contacts_analytic_value_company_idx on contacts (analytic_value_id, company_id);

comment on column contacts.analytic_value_id is
  'The analytic value the lines of a document naming this contact start with, at 100 %, on an axis the product left free. Pre-fills the line, never constrains it.';

-- ---------------------------------------------------------------------------
-- 3. Only a result account carries a split
--
-- One question, asked of an account: is it in the `income` or the `expense`
-- group? `internal_group` is derived from the account type, and the account
-- type is what the country pack gives every account of its chart. A null
-- account — a section or a note line — is not one.
-- ---------------------------------------------------------------------------

-- Security invoker, like the two refresh functions below: the guards that
-- call them are definers and lend them their rights, and a client calling one
-- directly reads and writes only what row level security lets it.

create or replace function assert_analytic_account(p_account_id uuid, p_what text)
returns void
language plpgsql
stable
as $$
declare
  v_code  text;
  v_group text;
begin
  select a.code, a.internal_group into v_code, v_group from accounts a where a.id = p_account_id;
  if v_group is null or v_group not in ('income', 'expense') then
    raise exception 'analytic_not_on_result_account: % is on %, and only an income or an expense account carries an analytic split',
      p_what, coalesce('account ' || v_code, 'no account')
      using errcode = 'check_violation',
            hint = 'a receivable, a payable, a tax or a bank line is not for an activity; split the income or expense line it belongs to';
  end if;
end;
$$;

comment on function assert_analytic_account(uuid, text) is
  'Refuses analytic_not_on_result_account unless the account is in the income or expense group (accounts.internal_group, from its account type). Read by the guards of document_line_analytics and entry_line_analytics.';

revoke execute on function assert_analytic_account(uuid, text) from public, anon;
grant execute on function assert_analytic_account(uuid, text) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 4. The guards of a split
--
-- The same three questions on both tables: is the line on a result account,
-- do the shares of this axis stay within 100, and — on a document — is the
-- document still a draft. An update that moves nothing but the derived
-- `amount` is the database writing it, and passes: it is also how a split
-- written before this file is left as it was.
-- ---------------------------------------------------------------------------

create or replace function document_line_analytics_guard()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_state   doc_state;
  v_number  text;
  v_type    doc_type;
  v_account uuid;
  v_seq     integer;
  v_axis    uuid;
  v_total   numeric;
begin
  if tg_op = 'UPDATE'
     and (new.document_line_id, new.analytic_value_id, new.percentage, new.company_id)
         is not distinct from (old.document_line_id, old.analytic_value_id, old.percentage, old.company_id) then
    return new;
  end if;

  -- The company is being deleted, and everything of it with it.
  if tg_op = 'DELETE' and not exists (select 1 from companies c where c.id = old.company_id) then
    return old;
  end if;

  -- A row written into a company the writer may not know of: nothing below
  -- is read for it. And only the row's own company is read, so a line of
  -- another company is the foreign key's to refuse, as a line of nobody is.
  if tg_op <> 'DELETE' then
    perform assert_writes_into_known_company(new.company_id);
  end if;

  select d.state, d.number, d.doc_type, l.account_id, l.sequence
    into v_state, v_number, v_type, v_account, v_seq
    from document_lines l
    join documents d on d.id = l.document_id
   where l.id = coalesce(new.document_line_id, old.document_line_id)
     and l.company_id = coalesce(new.company_id, old.company_id);

  -- No line: it is being deleted, and its split with it; or it does not
  -- exist, which is the foreign key's to say.
  if not found then
    return coalesce(new, old);
  end if;

  if v_state <> 'draft' then
    raise exception 'document_posted: the analytic split of line % of % % was issued with it. The ledger line carries it from now on; correct it there.',
      v_seq, v_type, coalesce(v_number, '')
      using errcode = '55006';
  end if;

  if tg_op = 'DELETE' then
    return old;
  end if;

  perform assert_analytic_account(v_account, format('line %s of %s %s', v_seq, v_type, coalesce(v_number, '(draft)')));

  select v.axis_id into v_axis from analytic_values v
   where v.id = new.analytic_value_id and v.company_id = new.company_id;
  select coalesce(sum(x.percentage), 0) into v_total
    from document_line_analytics x
    join analytic_values v on v.id = x.analytic_value_id
   where x.document_line_id = new.document_line_id
     and v.axis_id = v_axis
     and x.id <> new.id;
  if v_total + new.percentage > 100 then
    raise exception 'analytic_split_over_100: line % of % % would carry % %% on one axis; the shares of an axis add up to 100 at most',
      v_seq, v_type, coalesce(v_number, '(draft)'), v_total + new.percentage
      using errcode = 'check_violation',
            hint = 'change or remove the share already on that axis — a default the product or the contact pre-filled is one';
  end if;

  -- The amount is the database's: whatever the caller wrote is replaced
  -- after the row is in, by document_line_analytics_refresh().
  return new;
end;
$$;

comment on function document_line_analytics_guard() is
  'The split of a document line: refused on a document that is no longer a draft (document_posted), on a line whose account is not an income or expense account (analytic_not_on_result_account), and beyond 100 % on one axis (analytic_split_over_100).';

revoke execute on function document_line_analytics_guard() from public, anon, authenticated, service_role;

create trigger document_line_analytics_guard
  before insert or update or delete on document_line_analytics
  for each row execute function document_line_analytics_guard();

create or replace function entry_line_analytics_guard()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_account uuid;
  v_seq     integer;
  v_number  text;
  v_axis    uuid;
  v_total   numeric;
begin
  if tg_op = 'UPDATE'
     and (new.entry_line_id, new.analytic_value_id, new.percentage, new.company_id)
         is not distinct from (old.entry_line_id, old.analytic_value_id, old.percentage, old.company_id) then
    return new;
  end if;

  -- As on a document line: the writer's company first, and its rows only.
  perform assert_writes_into_known_company(new.company_id);

  select l.account_id, l.sequence, e.number
    into v_account, v_seq, v_number
    from entry_lines l
    join entries e on e.id = l.entry_id
   where l.id = new.entry_line_id
     and l.company_id = new.company_id;
  if not found then
    return new;
  end if;

  perform assert_analytic_account(v_account, format('line %s of entry %s', v_seq, coalesce(v_number, '(draft)')));

  select v.axis_id into v_axis from analytic_values v
   where v.id = new.analytic_value_id and v.company_id = new.company_id;
  select coalesce(sum(x.percentage), 0) into v_total
    from entry_line_analytics x
    join analytic_values v on v.id = x.analytic_value_id
   where x.entry_line_id = new.entry_line_id
     and v.axis_id = v_axis
     and x.id <> new.id;
  if v_total + new.percentage > 100 then
    raise exception 'analytic_split_over_100: line % of entry % would carry % %% on one axis; the shares of an axis add up to 100 at most',
      v_seq, coalesce(v_number, '(draft)'), v_total + new.percentage
      using errcode = 'check_violation',
            hint = 'change or remove the share already on that axis';
  end if;

  return new;
end;
$$;

comment on function entry_line_analytics_guard() is
  'The split of a ledger line: refused on a line whose account is not an income or expense account (analytic_not_on_result_account), and beyond 100 % on one axis (analytic_split_over_100).';

revoke execute on function entry_line_analytics_guard() from public, anon, authenticated, service_role;

create trigger entry_line_analytics_guard
  before insert or update on entry_line_analytics
  for each row execute function entry_line_analytics_guard();

-- ---------------------------------------------------------------------------
-- 5. The amounts are derived
--
-- The share of value k on an axis is the line rounded at the cumulated
-- percentage up to k, less the line rounded at the cumulated percentage
-- before k, in the order of the value codes. A split of 100 % adds up to its
-- line to the cent, and a split of 33.333 / 33.333 / 33.334 gives no cent to
-- nobody. Every split of a line is worked out again when one of its rows, or
-- the line, changes; the update writes only what moved, so the trigger it
-- fires in turn finds nothing to do.
-- ---------------------------------------------------------------------------

create or replace function analytic_refresh_document_line(p_line_id uuid)
returns void
language plpgsql
as $$
declare
  v_company  uuid;
  v_currency char(3);
  v_round    money_rounding;
begin
  select l.company_id, d.currency_code into v_company, v_currency
    from document_lines l
    join documents d on d.id = l.document_id
   where l.id = p_line_id;
  if not found then
    return;
  end if;
  v_round := rounding_of(v_company, v_currency);

  update document_line_analytics x
     set amount = s.share
    from (
      select x.id,
             round_amount(l.amount_untaxed * sum(x.percentage) over w / 100, v_round)
               - round_amount(l.amount_untaxed * (sum(x.percentage) over w - x.percentage) / 100, v_round) as share
        from document_line_analytics x
        join document_lines l on l.id = x.document_line_id
        join analytic_values v on v.id = x.analytic_value_id
       where x.document_line_id = p_line_id
      window w as (partition by v.axis_id order by v.code, v.id)
    ) s
   where x.id = s.id
     and x.amount is distinct from s.share;
end;
$$;

comment on function analytic_refresh_document_line(uuid) is
  'Writes the amount of every share of a document line''s split from its untaxed amount, rounded at the document''s currency, cumulated in the order of the value codes on each axis.';

revoke execute on function analytic_refresh_document_line(uuid) from public, anon;
grant execute on function analytic_refresh_document_line(uuid) to authenticated, service_role;

create or replace function analytic_refresh_entry_line(p_line_id uuid)
returns void
language plpgsql
as $$
declare
  v_company uuid;
  v_round   money_rounding;
begin
  select l.company_id into v_company from entry_lines l where l.id = p_line_id;
  if not found then
    return;
  end if;
  v_round := rounding_of(v_company);

  update entry_line_analytics x
     set amount = s.share
    from (
      select x.id,
             round_amount(l.balance * sum(x.percentage) over w / 100, v_round)
               - round_amount(l.balance * (sum(x.percentage) over w - x.percentage) / 100, v_round) as share
        from entry_line_analytics x
        join entry_lines l on l.id = x.entry_line_id
        join analytic_values v on v.id = x.analytic_value_id
       where x.entry_line_id = p_line_id
      window w as (partition by v.axis_id order by v.code, v.id)
    ) s
   where x.id = s.id
     and x.amount is distinct from s.share;
end;
$$;

comment on function analytic_refresh_entry_line(uuid) is
  'Writes the amount of every share of a ledger line''s split from its balance (debit minus credit) in the company''s currency, cumulated in the order of the value codes on each axis.';

revoke execute on function analytic_refresh_entry_line(uuid) from public, anon;
grant execute on function analytic_refresh_entry_line(uuid) to authenticated, service_role;

create or replace function document_line_analytics_refresh()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  if tg_op <> 'INSERT' then
    perform analytic_refresh_document_line(old.document_line_id);
  end if;
  if tg_op = 'INSERT' or (tg_op = 'UPDATE' and new.document_line_id <> old.document_line_id) then
    perform analytic_refresh_document_line(new.document_line_id);
  end if;
  return null;
end;
$$;

revoke execute on function document_line_analytics_refresh() from public, anon, authenticated, service_role;

create trigger document_line_analytics_refresh
  after insert or update or delete on document_line_analytics
  for each row execute function document_line_analytics_refresh();

create or replace function entry_line_analytics_refresh()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  if tg_op <> 'INSERT' then
    perform analytic_refresh_entry_line(old.entry_line_id);
  end if;
  if tg_op = 'INSERT' or (tg_op = 'UPDATE' and new.entry_line_id <> old.entry_line_id) then
    perform analytic_refresh_entry_line(new.entry_line_id);
  end if;
  return null;
end;
$$;

revoke execute on function entry_line_analytics_refresh() from public, anon, authenticated, service_role;

create trigger entry_line_analytics_refresh
  after insert or update or delete on entry_line_analytics
  for each row execute function entry_line_analytics_refresh();

-- A line that changes amount or account takes its split with it: the shares
-- are worked out again, and a split on a line moved to a balance-sheet
-- account is refused as it would be on insert.

create or replace function document_lines_analytics_follow()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  if not exists (select 1 from document_line_analytics x where x.document_line_id = new.id) then
    return null;
  end if;
  if new.account_id is distinct from old.account_id then
    perform assert_analytic_account(new.account_id, format('line %s, which carries an analytic split,', new.sequence));
  end if;
  perform analytic_refresh_document_line(new.id);
  return null;
end;
$$;

revoke execute on function document_lines_analytics_follow() from public, anon, authenticated, service_role;

create trigger document_lines_analytics_follow
  after update on document_lines
  for each row
  when (old.amount_untaxed is distinct from new.amount_untaxed
        or old.account_id is distinct from new.account_id)
  execute function document_lines_analytics_follow();

create or replace function entry_lines_analytics_follow()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  if not exists (select 1 from entry_line_analytics x where x.entry_line_id = new.id) then
    return null;
  end if;
  if new.account_id is distinct from old.account_id then
    perform assert_analytic_account(new.account_id, format('line %s, which carries an analytic split,', new.sequence));
  end if;
  perform analytic_refresh_entry_line(new.id);
  return null;
end;
$$;

revoke execute on function entry_lines_analytics_follow() from public, anon, authenticated, service_role;

create trigger entry_lines_analytics_follow
  after update on entry_lines
  for each row
  when (old.debit is distinct from new.debit
        or old.credit is distinct from new.credit
        or old.account_id is distinct from new.account_id)
  execute function entry_lines_analytics_follow();

-- ---------------------------------------------------------------------------
-- 6. The defaults pre-fill the line
--
-- When a line is written, or its product changes, each default whose axis
-- the line has no share on yet is added at 100 %: the product's first, then
-- the contact's of the document. Only on a result account: a default does
-- not apply to a line that cannot carry it, and says nothing. What it wrote
-- is a row like any other, which the person changes or removes.
-- ---------------------------------------------------------------------------

create or replace function document_lines_analytic_defaults()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_value uuid;
begin
  if new.line_type <> 'product'
     or not exists (select 1 from accounts a
                     where a.id = new.account_id and a.internal_group in ('income', 'expense')) then
    return null;
  end if;

  for v_value in
    select c.value
      from (
        select p.analytic_value_id as value, 1 as rank
          from products p where p.id = new.product_id
        union all
        select k.analytic_value_id, 2
          from documents d join contacts k on k.id = d.contact_id
         where d.id = new.document_id
      ) c
     where c.value is not null
     order by c.rank
  loop
    if not exists (
      select 1
        from document_line_analytics x
        join analytic_values v on v.id = x.analytic_value_id
       where x.document_line_id = new.id
         and v.axis_id = (select axis_id from analytic_values where id = v_value)
    ) then
      insert into document_line_analytics (company_id, document_line_id, analytic_value_id, percentage)
      values (new.company_id, new.id, v_value, 100);
    end if;
  end loop;
  return null;
end;
$$;

comment on function document_lines_analytic_defaults() is
  'Pre-fills the analytic split of a document line from the default value of its product, then of the document''s contact, at 100 % on each axis the line has no share on yet, and only on an income or expense account. Never replaces what the line carries.';

revoke execute on function document_lines_analytic_defaults() from public, anon, authenticated, service_role;

create trigger document_lines_analytic_defaults
  after insert or update of product_id on document_lines
  for each row execute function document_lines_analytic_defaults();

-- A split already written is put to the amounts this file derives. The guard
-- lets an update of the amount alone through, so a split written before it
-- on any account is left where it is.
do $$
declare
  v_line uuid;
begin
  for v_line in select distinct entry_line_id from entry_line_analytics loop
    perform analytic_refresh_entry_line(v_line);
  end loop;
end;
$$;

-- ---------------------------------------------------------------------------
-- 7. The split of a group of document lines
--
-- What `post_document()` groups lines by, beside their account and tax: two
-- lines with the same split are one ledger line, two lines with different
-- splits are two. Null for a line with none, which is every line written
-- before this file, so a document without a split posts as it always did.
-- ---------------------------------------------------------------------------

create or replace function document_line_split_key(p_line_id uuid)
returns text
language sql
stable
as $$
  select string_agg(x.analytic_value_id::text || '=' || x.percentage::text, ',' order by x.analytic_value_id)
    from document_line_analytics x
   where x.document_line_id = p_line_id;
$$;

comment on function document_line_split_key(uuid) is
  'The analytic split of a document line as one text, null when it has none. post_document() groups lines by it.';

revoke execute on function document_line_split_key(uuid) from public, anon;
grant execute on function document_line_split_key(uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 8. post_document, which carries the split onto the ledger
--
-- `20260921145425` as it was, with two changes: the bases, and the share of a
-- tax booked on the accounts of the lines, are grouped by the analytic split
-- of the lines as well as by account and tax; and each ledger line written for
-- a group takes the split of that group. A document whose lines carry no split
-- groups and books exactly as before.
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
  -- The ledger line just written, which takes the analytic split of the
  -- document lines it groups.
  v_line       uuid;
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
  -- The day the tax falls due, which is not the day the entry is booked on.
  v_tax_point  date;
  v_postings   integer;
  -- Where the three parties of this document are, resolved once and kept on
  -- the document. `document_territory()` is the ladder.
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

  -- Where the three parties of this document are. Resolved on every document
  -- now and not only where a tax asks, because the answer is kept: it is
  -- written on the document beside its entry, at the end of this function,
  -- and a posted document does not change it afterwards.
  v_terr_seller := document_territory(p_document_id, 'seller');
  v_terr_buyer  := document_territory(p_document_id, 'buyer');
  v_terr_supply := document_territory(p_document_id, 'supply');

  -- Every tax that names a territory must find the parties where it says they
  -- are. This is the one thing the core may do with a territory condition: it
  -- refuses a tax that cannot apply, and it never chooses, substitutes or
  -- suggests one — the core picks no tax for anybody, in any country.
  --
  -- "Inside" is `territory_within_for_tax()`: the tree of `territories`, cut
  -- at every territory the reference data takes out of its parent's tax. A
  -- supply to such a territory does not satisfy a condition naming the
  -- parent, which is how a country's rates stop at the territories its own
  -- law excludes without a pack writing a negation.
  --
  -- The loop is skipped entirely where nothing asks, which is every document
  -- of every pack that names no territory.
  for r in
    select distinct t.code,
           t.applies_seller_territory as seller,
           t.applies_buyer_territory  as buyer,
           t.applies_supply_territory as supply,
           t.applies_supply_vs_seller as relation
      from document_lines l
      join taxes t on t.id = l.tax_id
     where l.document_id = p_document_id
       and (t.applies_seller_territory is not null
         or t.applies_buyer_territory  is not null
         or t.applies_supply_territory is not null
         or t.applies_supply_vs_seller is not null)
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
      if not territory_within_for_tax(p.actual, p.wanted) then
        raise exception 'tax_territory_mismatch: tax % applies where the % is in %; on this document the % is in %',
          r.code, p.party, p.wanted, p.party, p.actual;
      end if;
    end loop;

    -- The relation between two facts the document already carries: is the
    -- supply inside the seller's territory, or not. It is read at the level of
    -- the seller — a seller in US-CA shipping to US-AZ is `other`, and one in
    -- US-CA delivering in US-CA is `same` — so a seller known only by a whole
    -- country has no level to read it at. That is refused rather than
    -- answered: a country is where no tax that asks this question is levied,
    -- and "same" against a country would hold for every domestic supply of
    -- every state at once.
    if r.relation is not null then
      if v_terr_seller is null then
        raise exception 'no_party_territory: tax % compares the place of supply with the territory of the seller, and nothing on this document says where the seller is; set territory_code on the party that sells, or the country beside it',
          r.code;
      end if;
      if v_terr_supply is null then
        raise exception 'no_party_territory: tax % compares the place of supply with the territory of the seller, and nothing on this document says where the supply is; set supply_territory_code or delivery_country on the document',
          r.code;
      end if;
      if not exists (select 1 from territories t
                      where t.code = upper(btrim(v_terr_seller)) and t.parent_code is not null) then
        raise exception 'no_party_territory: tax % compares the place of supply with the territory of the seller, and the seller is in %, which is not a territory inside a country; set territory_code on the party that sells to the territory that levies this tax',
          r.code, v_terr_seller;
      end if;
      if territory_within_for_tax(v_terr_supply, v_terr_seller) <> (r.relation = 'same') then
        raise exception 'tax_territory_mismatch: tax % applies where the supply is % the territory of the seller (%); on this document the supply is in %',
          r.code,
          case when r.relation = 'same' then 'inside' else 'outside' end,
          v_terr_seller, v_terr_supply;
      end if;
    end if;
  end loop;

  -- Totals are derived; make sure they reflect the lines as they stand now.
  perform documents_refresh_totals(p_document_id);
  select * into v_doc from documents where id = p_document_id;

  select c.currency_code into v_home from companies c where c.id = v_doc.company_id;
  v_rate    := v_doc.exchange_rate;
  v_foreign := v_doc.currency_code <> v_home;
  v_round      := rounding_of(v_doc.company_id, v_doc.currency_code);
  v_book_round := rounding_of(v_doc.company_id);

  -- When the tax on this document falls due, under the rule its country
  -- declares. A document that carries BT-7 has been told and nobody overrides
  -- it; otherwise `tax_point_of()` reads the country's word. The payment
  -- argument is null here and says so: matching needs the entry this function
  -- is writing, so at posting time no payment of this document has been
  -- recorded, and a rule whose earliest branch is a payment falls back on the
  -- branch it can see. Null comes back where the rule is `payment_date` or the
  -- country declared none, and null on a line means "the entry's own date",
  -- which is the reading every ledger written before this one had.
  v_tax_point := coalesce(
    v_doc.tax_point_date,
    tax_point_of(v_doc.company_id, v_doc.document_date, v_doc.delivery_date, null));

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
           string_agg(distinct l.name, ', ') as label,
           (array_agg(l.id order by l.sequence))[1] as first_line
      from document_lines l
     where l.document_id = p_document_id
       and l.line_type = 'product'
     -- The split is part of the key: lines that go to different analytic
     -- values are different ledger lines (decision 0075).
     group by l.account_id, l.tax_id, document_line_split_key(l.id)
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
                             declaration_box, box_amount, tax_point_date,
                             currency_code, amount_currency)
    values (v_entry.id, v_doc.company_id, r.account_id, v_seq, left(r.label, 200),
            case when v_base_credit then 0 else v_book end,
            case when v_base_credit then v_book else 0 end,
            r.tax_id, false, p.posting_type,
            case when coalesce(p.cash_basis, false) then null else p.declaration_box end,
            case when p.declaration_box is null then null
                 else round_amount(r.base_amount * coalesce(p.box_factor_percent, 100) / 100 / v_rate,
                                   v_book_round) end,
            v_tax_point,
            v_doc.currency_code,
            case when v_foreign then v_amount end)
    returning id into v_line;

    -- Every line of the group carries the same split; the first one says it.
    insert into entry_line_analytics (company_id, entry_line_id, analytic_value_id, percentage)
    select v_doc.company_id, v_line, x.analytic_value_id, x.percentage
      from document_line_analytics x
     where x.document_line_id = r.first_line;
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
                                 declaration_box, box_amount, tax_point_date,
                                 currency_code, amount_currency)
        values (v_entry.id, v_doc.company_id,
                case when v_cash then v_transition else p.account_id end,
                v_seq, r.tax_name,
                case when v_side_credit then 0 else v_book end,
                case when v_side_credit then v_book else 0 end,
                r.tax_id, true, p.posting_type,
                case when v_cash then null else p.declaration_box end,
                v_box_amount, v_tax_point, v_doc.currency_code,
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
               first_line,
               sum(base_amount) over ()                                   as total_base,
               row_number() over (order by seq) = count(*) over ()         as is_last
          from (
            select l.account_id,
                   sum(l.amount_untaxed) as base_amount,
                   min(l.sequence)       as seq,
                   (array_agg(l.id order by l.sequence))[1] as first_line
              from document_lines l
             where l.document_id = p_document_id
               and l.line_type = 'product'
               and l.tax_id = r.tax_id
             -- A cost lands where its lines do, analytic split included.
             group by l.account_id, document_line_split_key(l.id)
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
                                 declaration_box, box_amount, tax_point_date,
                                 currency_code, amount_currency)
        values (v_entry.id, v_doc.company_id, g.account_id, v_seq, r.tax_name,
                case when v_side_credit then 0 else v_share_book end,
                case when v_side_credit then v_share_book else 0 end,
                r.tax_id, false, p.posting_type,
                p.declaration_box, v_share_box, v_tax_point, v_doc.currency_code,
                case when v_foreign then v_share end)
        returning id into v_line;

        insert into entry_line_analytics (company_id, entry_line_id, analytic_value_id, percentage)
        select v_doc.company_id, v_line, x.analytic_value_id, x.percentage
          from document_line_analytics x
         where x.document_line_id = g.first_line;
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
         accounting_date = v_date,
         tax_point_date  = v_tax_point,
         seller_territory_code     = v_terr_seller,
         buyer_territory_code      = v_terr_buyer,
         supply_territory_resolved = v_terr_supply
   where id = p_document_id;

  return v_entry;
end;
$$;

comment on function post_document(uuid) is
  'Books a document: one entry, the bases on the accounts of the lines, the tax of each group rounded once and shared over the postings of the tax, each ledger line naming the posting type that wrote it. Refuses a tax whose applies_*_territory the document contradicts — read with territory_within_for_tax(), so a territory outside its parent''s tax does not satisfy a condition naming the parent — or whose applies_supply_vs_seller it contradicts, by name, before anything reaches the ledger; chooses no tax for anybody. Writes the three territories it resolved on the document (seller_territory_code, buyer_territory_code, supply_territory_resolved). Groups the lines by account, tax and analytic split, and copies the split of each group onto the ledger line it writes (decision 0075).';

-- ---------------------------------------------------------------------------
-- 9. cancel_document, whose credit note takes the split of the invoice
--
-- `20260919090000` as it was, with the analytic split of each line copied onto
-- the line of the credit note that undoes it. The invoice's ledger lines carry
-- the split, so the credit note's must carry it too, or a cancelled sale would
-- stay in the result of its project and leave the unassigned row instead.
-- ---------------------------------------------------------------------------

create or replace function cancel_document(p_document_id uuid, p_date date default null)
returns documents
language plpgsql
as $$
declare
  v_doc    documents%rowtype;
  v_credit documents%rowtype;
  v_date   date;
  v_type   doc_type;
  v_other  text;
  v_line   uuid;
  r        record;
begin
  select * into v_doc from documents where id = p_document_id for update;
  if not found then
    raise exception 'unknown_document: document % does not exist', p_document_id;
  end if;

  if v_doc.doc_type in ('sale_credit_note', 'purchase_credit_note') then
    raise exception 'document_is_a_credit_note: % % undoes another document. A credit note is not cancelled by another; issue the invoice again.',
      v_doc.doc_type, coalesce(v_doc.number, v_doc.id::text);
  end if;

  if v_doc.state = 'cancelled' then
    raise exception 'document_already_cancelled: % % is already cancelled',
      v_doc.doc_type, coalesce(v_doc.number, v_doc.id::text);
  end if;

  if v_doc.state <> 'posted' then
    raise exception 'document_not_posted: % % is a %, which is changed or deleted, not cancelled by a credit note',
      v_doc.doc_type, coalesce(v_doc.number, v_doc.id::text), v_doc.state;
  end if;

  v_type := case v_doc.doc_type
              when 'sale_invoice' then 'sale_credit_note'
              when 'purchase_invoice' then 'purchase_credit_note'
            end::doc_type;
  if v_type is null then
    raise exception 'document_not_accountable: a % is not cancelled by a credit note', v_doc.doc_type;
  end if;

  select coalesce(c.number, c.id::text) into v_other
    from documents c
   where c.reversed_document_id = v_doc.id and c.state = 'posted'
   limit 1;
  if found then
    raise exception 'document_already_credited: % % is already credited by %. Cancelling it would credit it twice.',
      v_doc.doc_type, v_doc.number, v_other;
  end if;

  if v_doc.amount_paid <> 0
     or exists (select 1 from entry_lines l where l.entry_id = v_doc.entry_id and l.matched_amount > 0) then
    raise exception 'document_paid: % % is settled by % already. Undo that matching first with unreconcile() — the money it records came in and stays — then cancel the document.',
      v_doc.doc_type, v_doc.number, v_doc.amount_paid;
  end if;

  -- The matching is part of the gesture; see reverse_entry().
  if not is_installer() and not has_capability(v_doc.company_id, 'reconcile.write') then
    raise exception 'not_allowed: cancelling % matches it with its credit note, which needs reconcile.write',
      v_doc.number
      using errcode = '42501';
  end if;

  v_date := p_date;
  if v_date is null then
    begin
      perform assert_period_open(v_doc.company_id, coalesce(v_doc.accounting_date, v_doc.document_date), true);
    exception when sqlstate '55006' then
      raise exception 'reversal_date_needed: % % is booked on %, which is no longer open (%). Pass the date of an open period to issue the credit note on.',
        v_doc.doc_type, v_doc.number, coalesce(v_doc.accounting_date, v_doc.document_date), sqlerrm
        using errcode = '55006';
    end;
    v_date := coalesce(v_doc.accounting_date, v_doc.document_date);
  elsif v_date < coalesce(v_doc.accounting_date, v_doc.document_date) then
    raise exception 'reversal_before_original: % % is booked on %, and is not cancelled on % — before it was issued.',
      v_doc.doc_type, v_doc.number, coalesce(v_doc.accounting_date, v_doc.document_date), v_date;
  end if;

  insert into documents (company_id, doc_type, contact_id, journal_id, document_date,
                         accounting_date, due_date, currency_code, exchange_rate,
                         supplier_reference, buyer_reference, project_reference,
                         contract_reference, order_reference,
                         delivery_address_line1, delivery_postal_code, delivery_city,
                         delivery_country, supply_territory_code, payment_means_code,
                         payee_iban, currency_code_tax, reversed_document_id, note)
  values (v_doc.company_id, v_type, v_doc.contact_id, v_doc.journal_id, v_date,
          v_date, v_date, v_doc.currency_code, v_doc.exchange_rate,
          v_doc.supplier_reference, v_doc.buyer_reference, v_doc.project_reference,
          v_doc.contract_reference, v_doc.order_reference,
          v_doc.delivery_address_line1, v_doc.delivery_postal_code, v_doc.delivery_city,
          v_doc.delivery_country, v_doc.supply_territory_code, v_doc.payment_means_code,
          v_doc.payee_iban, v_doc.currency_code_tax, v_doc.id,
          'Cancels ' || v_doc.number)
  returning * into v_credit;

  -- Line by line, so each line of the credit note knows the line it undoes:
  -- it takes that line's analytic split as it was issued, over whatever a
  -- product or a contact pre-filled since.
  for r in
    select l.* from document_lines l
     where l.document_id = v_doc.id
     order by l.sequence, l.id
  loop
    insert into document_lines (document_id, company_id, sequence, line_type, name, description,
                                quantity, unit_code, unit_price, discount_percent,
                                tax_id, account_id, product_id)
    values (v_credit.id, r.company_id, r.sequence, r.line_type, r.name, r.description,
            r.quantity, r.unit_code, r.unit_price, r.discount_percent,
            r.tax_id, r.account_id, r.product_id)
    returning id into v_line;

    delete from document_line_analytics x where x.document_line_id = v_line;
    insert into document_line_analytics (company_id, document_line_id, analytic_value_id, percentage)
    select x.company_id, v_line, x.analytic_value_id, x.percentage
      from document_line_analytics x
     where x.document_line_id = r.id;
  end loop;

  select * into v_credit from documents where id = v_credit.id;
  if (v_credit.amount_untaxed, v_credit.amount_tax, v_credit.amount_total)
     is distinct from (v_doc.amount_untaxed, v_doc.amount_tax, v_doc.amount_total) then
    raise exception 'credit_note_differs: the lines of % give % today, and it was issued at %. A tax or a rounding it was posted with has changed since; credit it by hand, line by line.',
      v_doc.number, v_credit.amount_total, v_doc.amount_total;
  end if;

  perform post_document(v_credit.id);
  select * into v_credit from documents where id = v_credit.id;
  perform match_reversal(v_doc.entry_id, v_credit.entry_id);

  update documents set state = 'cancelled' where id = v_doc.id;

  select * into v_credit from documents where id = v_credit.id;
  return v_credit;
end;
$$;

comment on function cancel_document(uuid, date) is
  'Undoes a posted invoice: writes its credit note — the same lines, taxes, accounts, contact, currency, rate and analytic split — naming it in reversed_document_id, posts it through post_document(), matches the two entries and marks the invoice cancelled. Returns the credit note. Dated on the invoice''s booking day while that period is open, and otherwise refused until a date is given (reversal_date_needed). Refused for a document that is not a posted invoice, is already cancelled or credited, or is settled in part or in full (unreconcile() first).';
