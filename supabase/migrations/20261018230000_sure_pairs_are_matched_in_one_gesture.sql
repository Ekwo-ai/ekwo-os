-- Ekwo OS — the sure pairs are matched in one gesture, and what undoes an
-- entry is matched with it as it is posted (decision 0075).
--
-- A matching screen over books brought in from elsewhere opens on hundreds of
-- proposals, and most of them are not questions: one invoice of 1 200.00 and
-- one payment of 1 200.00 of the same customer, nothing else of that amount;
-- a subscription of 49.00 billed every month and paid every month. A person
-- who has to click each of them reads none of them.
--
-- **What is sure, said by one function.** `suggest_sure_pairs(company,
-- contact)` gives the pairs whose evidence leaves nothing to choose, one row
-- per pair, each line once, exact to the cent, never across counterparties or
-- accounts, and says which evidence:
--
--   * `same_document` — both lines are of one document, or the settlement's
--     entry carries the document's number or payment reference;
--   * `reversal` — one line's entry undoes the other's (`reversed_entry_id`),
--     or a credit note names the invoice (`reversed_document_id`);
--   * `unique_amount` — exactly one open debit and one open credit of that
--     amount for that counterparty on that account;
--   * `recurring_in_date_order` — several lines of one amount: the oldest
--     invoice is paired with the first settlement dated on or after it, then
--     the next, each line once. A settlement dated before an invoice is never
--     its pair under this rule.
--
-- Each rule reads what the earlier ones left. The lines searched are the ones
-- `suggest_item_combinations()` searches, read by one function,
-- `matchable_lines()`, which both now call.
--
-- **One gesture, undone as one.** `reconcile_batch(pairs)` matches each pair
-- through `match_lines()` — the checks of `reconcile_many()`, then
-- `reconcile()` — and records the gesture in `reconciliation_batches`, named
-- on each matching it wrote. One refusal refuses the whole batch, and the
-- refusal says which pair. `unreconcile_batch(batch)` undoes every matching
-- of the gesture still standing through `unreconcile()`, and records when
-- and by whom.
--
-- **What undoes an entry is matched as it is posted.** `reverse_entry()` and
-- `cancel_document()` already matched their mirror, after posting it. Three
-- paths did not: a reversal written as a draft naming its entry and posted by
-- `post_entry()`; a credit note naming its invoice, posted by
-- `post_document()` for part of it; and the mirror `unreconcile()` posts to
-- take back an exchange difference, which left two open lines behind. A
-- trigger on each of the two posting transitions now calls `match_reversal()`
-- — the one pairing of a mirror with what it mirrors — when the caller may
-- match (`reconcile.write`, and `settings.read`, where reconcilable is
-- written). A caller who may not leaves both open, as before, and
-- `suggest_sure_pairs()` proposes them as `reversal`. A payment is not
-- matched here: `payments` names no document, and the library that records a
-- payment of a document already matches it with that document's open items.

-- ---------------------------------------------------------------------------
-- 1. The lines the matching searches, read once
-- ---------------------------------------------------------------------------

create or replace function matchable_lines(
  p_company_id uuid,
  p_contact_id uuid default null
)
returns table (
  line_id              uuid,
  account_id           uuid,
  account_type         text,
  side                 text,
  amount_open          numeric,
  entry_date           date,
  party                uuid,
  entry_id             uuid,
  reversed_entry_id    uuid,
  document_id          uuid,
  reversed_document_id uuid,
  document_number      text,
  payment_reference    text,
  entry_reference      text
)
language sql
stable
security invoker
as $$
  -- Open receivable and payable lines that name somebody, in the company's
  -- currency: a branch and its parent are one party, as for `reconcile()`.
  -- Row level security answers the read of the company: one the caller
  -- cannot read gives nothing.
  select i.line_id, i.account_id, a.account_type::text, i.side, i.amount_open, i.entry_date,
         commercial_entity(i.contact_id),
         l.entry_id, e.reversed_entry_id,
         d.id, d.reversed_document_id, d.number, d.payment_reference, e.reference
  from companies c
  cross join lateral open_items(c.id, null, null, true) i
  join entry_lines l on l.id = i.line_id
  join entries e     on e.id = l.entry_id
  join accounts a    on a.id = i.account_id
  left join documents d on d.id = i.document_id
  where c.id = p_company_id
    and i.contact_id is not null
    and (l.currency_code is null or l.currency_code = c.currency_code or coalesce(l.amount_currency, 0) = 0)
    and (p_contact_id is null or commercial_entity(i.contact_id) = commercial_entity(p_contact_id));
$$;

comment on function matchable_lines(uuid, uuid) is
  'The open receivable and payable lines the matching searches: posted, naming a contact, in the company''s currency, each with its party (commercial_entity()), its entry and what that entry or its document undoes, and the references a settlement may carry. Of one party when p_contact_id is given. Read by suggest_item_combinations() and suggest_sure_pairs().';

revoke execute on function matchable_lines(uuid, uuid) from public, anon;
grant execute on function matchable_lines(uuid, uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 2. suggest_item_combinations — `20261018210000`, through matchable_lines()
-- ---------------------------------------------------------------------------

create or replace function suggest_item_combinations(
  p_company_id uuid,
  p_contact_id uuid default null
)
returns table (
  proposal_id   uuid,
  ordinal       integer,
  contact_id    uuid,
  account_id    uuid,
  line_id       uuid,
  side          text,
  amount        numeric,
  kind          text,
  line_ids      uuid[],
  total         numeric,
  difference    numeric,
  because       text,
  alternatives  integer
)
language plpgsql
stable
security invoker
as $$
declare
  v_home      char(3);
  v_policy    matching_policy;
  v_round     money_rounding;
  v_tolerance numeric;
  v_bounds    record;
  s           record;
  v_found     jsonb;
  v_exact     integer;
  v_subset    integer[];
  v_k         integer;
  p           record;
begin
  -- Row level security answers this select: a company the caller cannot
  -- read gives no row, as a company that does not exist.
  select c.currency_code into v_home from companies c where c.id = p_company_id;
  if v_home is null then return; end if;

  v_policy    := matching_policy_of(p_company_id);
  v_round     := rounding_of(p_company_id);
  v_tolerance := v_policy.difference_tolerance_units * currency_unit(v_round);
  select * into v_bounds from matching_search_bounds();

  for s in
    with scoped as (
      select m.line_id, m.account_id, m.side, m.amount_open, m.entry_date, m.party
      from matchable_lines(p_company_id, p_contact_id) m
    ),
    pairs as (
      select o.line_id as single_id, o.account_id, o.side, o.amount_open, o.entry_date, o.party,
             c.line_id as candidate_id, c.amount_open as candidate_amount, c.entry_date as candidate_date,
             row_number() over (partition by o.line_id
                                order by abs(c.entry_date - o.entry_date), c.entry_date, c.line_id) as rn
      from scoped o
      join scoped c on c.party = o.party and c.account_id = o.account_id and c.side <> o.side
    )
    select pr.single_id, pr.account_id, pr.side, pr.amount_open, pr.entry_date, pr.party,
           ct.name as party_name,
           array_agg(pr.candidate_id order by pr.candidate_date, pr.candidate_id) as ids,
           array_agg(pr.candidate_amount order by pr.candidate_date, pr.candidate_id) as amounts
    from pairs pr
    join contacts ct on ct.id = pr.party
    where pr.rn <= v_bounds.max_candidates
    group by pr.single_id, pr.account_id, pr.side, pr.amount_open, pr.entry_date, pr.party, ct.name
    order by ct.name, pr.party, pr.account_id, pr.entry_date, pr.single_id
  loop
    v_found := '[]'::jsonb;

    -- 1. One line of the other side for the same amount. Said once, from
    --    the debit, since the credit would say the same pair again.
    if s.side = 'debit' then
      for v_k in 1..cardinality(s.ids) loop
        exit when jsonb_array_length(v_found) >= v_bounds.max_proposals;
        if s.amounts[v_k] = s.amount_open then
          v_found := v_found || jsonb_build_object(
            'ids', jsonb_build_array(s.ids[v_k]), 'total', s.amounts[v_k]);
        end if;
      end loop;
    end if;

    -- 2. Several lines of the other side that add up to it, to the cent.
    if jsonb_array_length(v_found) < v_bounds.max_proposals then
      for v_subset in
        select x from combination_subsets(s.amounts, s.amount_open, 0, 2,
                                          v_bounds.max_proposals - jsonb_array_length(v_found)) x
      loop
        v_found := v_found || jsonb_build_object(
          'ids', (select jsonb_agg(s.ids[k] order by n) from unnest(v_subset) with ordinality u(k, n)),
          'total', (select sum(s.amounts[k]) from unnest(v_subset) k));
      end loop;
    end if;
    v_exact := jsonb_array_length(v_found);

    -- 3. Nothing exact: what a person could close by booking a difference no
    --    larger than the company allows — a pair first, the nearest amount
    --    first, then several lines.
    if v_exact = 0 and v_tolerance > 0 then
      if s.side = 'debit' then
        for v_k in
          select k from generate_subscripts(s.amounts, 1) k
          where abs(s.amounts[k] - s.amount_open) > 0
            and abs(s.amounts[k] - s.amount_open) <= v_tolerance
          order by abs(s.amounts[k] - s.amount_open), k
        loop
          exit when jsonb_array_length(v_found) >= v_bounds.max_proposals;
          v_found := v_found || jsonb_build_object(
            'ids', jsonb_build_array(s.ids[v_k]), 'total', s.amounts[v_k]);
        end loop;
      end if;
      if jsonb_array_length(v_found) < v_bounds.max_proposals then
        for v_subset in
          select x from combination_subsets(s.amounts, s.amount_open, v_tolerance, 2,
                                            v_bounds.max_proposals - jsonb_array_length(v_found)) x
        loop
          v_found := v_found || jsonb_build_object(
            'ids', (select jsonb_agg(s.ids[k] order by n) from unnest(v_subset) with ordinality u(k, n)),
            'total', (select sum(s.amounts[k]) from unnest(v_subset) k));
        end loop;
      end if;
    end if;

    for p in
      select f.value, f.ordinality::integer as n
      from jsonb_array_elements(v_found) with ordinality f
    loop
      line_ids     := array(select jsonb_array_elements_text(p.value->'ids')::uuid);
      total        := (p.value->>'total')::numeric;
      difference   := s.amount_open - total;
      proposal_id  := md5(s.single_id::text || ':' ||
                          array_to_string(array(select x::text from unnest(line_ids) x order by 1), ','))::uuid;
      ordinal      := p.n;
      contact_id   := s.party;
      account_id   := s.account_id;
      line_id      := s.single_id;
      side         := s.side;
      amount       := s.amount_open;
      kind         := case when cardinality(line_ids) = 1 then 'pair' else 'combination' end;
      alternatives := jsonb_array_length(v_found);
      because := case
        when difference = 0 and cardinality(line_ids) = 1 then
          format('one open item of %s on the other side is for the same amount, %s', s.party_name, total)
        when difference = 0 then
          format('%s open items of %s on the other side add up to %s, the amount of this line',
                 cardinality(line_ids), s.party_name, total)
        when cardinality(line_ids) = 1 then
          format('one open item of %s on the other side is for %s, %s %s than this line: a difference to book',
                 s.party_name, total, abs(difference), case when difference > 0 then 'less' else 'more' end)
        else
          format('%s open items of %s on the other side add up to %s, %s %s than this line: a difference to book',
                 cardinality(line_ids), s.party_name, total, abs(difference),
                 case when difference > 0 then 'less' else 'more' end)
      end;
      return next;
    end loop;
  end loop;
end;
$$;

comment on function suggest_item_combinations(uuid, uuid) is
  'What open receivable and payable lines of one counterparty on one account could settle each other — of the company, or of one contact (a branch and its parent are one party), as matchable_lines() reads them. For each open line (line_id), up to three proposals, in this order: one line of the other side for the same amount (kind pair, said once, from the debit), several lines that add up to it to the cent (kind combination, found by combination_subsets()), and only when nothing is exact, a pair then several lines within the company''s difference tolerance (difference, signed: the line less the total). proposal_id is stable for the same lines; alternatives counts the proposals of the line. Lines in another currency than the company''s are not searched. It writes nothing and decides nothing: reconcile_many() and reconcile_with_difference() settle a proposal a person chose; suggest_sure_pairs() says which pairs leave nothing to choose.';

-- ---------------------------------------------------------------------------
-- 3. suggest_sure_pairs — the pairs that leave nothing to choose
-- ---------------------------------------------------------------------------

create or replace function suggest_sure_pairs(
  p_company_id uuid,
  p_contact_id uuid default null
)
returns table (
  debit_line_id  uuid,
  credit_line_id uuid,
  contact_id     uuid,
  account_id     uuid,
  amount         numeric,
  evidence       text
)
language plpgsql
stable
security invoker
as $$
declare
  v_used    jsonb := '{}'::jsonb;
  v_out     jsonb := '[]'::jsonb;
  s         record;
  g         record;
  v_inv     uuid[];
  v_inv_at  date[];
  v_set     uuid[];
  v_set_at  date[];
  v_i       integer;
  v_j       integer;
begin
  -- 1. What the entries say: a line of one document and the line that
  --    settles it under that document's reference, and a line and the line
  --    of what undoes it. The strongest first; each line once.
  for s in
    with m as (
      select * from matchable_lines(p_company_id, p_contact_id)
    ),
    candidates as (
      select d.line_id as d_id, c.line_id as c_id, d.party, d.account_id, d.amount_open,
             d.entry_date as d_at, c.entry_date as c_at,
             (d.document_id is not null and d.document_id = c.document_id)
             or (d.document_id is not null and c.document_id is null
                 and nullif(lower(btrim(c.entry_reference)), '') in
                     (lower(btrim(d.document_number)), lower(btrim(d.payment_reference))))
             or (c.document_id is not null and d.document_id is null
                 and nullif(lower(btrim(d.entry_reference)), '') in
                     (lower(btrim(c.document_number)), lower(btrim(c.payment_reference))))
               as same_document,
             d.reversed_entry_id = c.entry_id
             or c.reversed_entry_id = d.entry_id
             or (d.reversed_document_id is not null and d.reversed_document_id = c.document_id)
             or (c.reversed_document_id is not null and c.reversed_document_id = d.document_id)
               as reversal
      from m d
      join m c on c.party = d.party and c.account_id = d.account_id
              and c.amount_open = d.amount_open and c.side = 'credit'
      where d.side = 'debit'
    )
    select x.*, case when x.same_document then 'same_document' else 'reversal' end as evidence
    from candidates x
    where x.same_document or x.reversal
    order by case when x.same_document then 1 else 2 end, x.d_at, x.d_id, x.c_at, x.c_id
  loop
    continue when v_used ? s.d_id::text or v_used ? s.c_id::text;
    v_used := v_used || jsonb_build_object(s.d_id::text, true, s.c_id::text, true);
    v_out  := v_out || jsonb_build_object(
      'debit_line_id', s.d_id, 'credit_line_id', s.c_id, 'contact_id', s.party,
      'account_id', s.account_id, 'amount', s.amount_open, 'evidence', s.evidence, 'at', s.d_at);
  end loop;

  -- 2. What the amounts say, of what is left, one counterparty, one account
  --    and one amount at a time.
  for g in
    with m as (
      select * from matchable_lines(p_company_id, p_contact_id) x
      where not v_used ? x.line_id::text
    )
    select m.party, m.account_id, m.account_type, m.amount_open,
           array_agg(m.line_id order by m.entry_date, m.line_id) filter (where m.side = 'debit') as d_ids,
           array_agg(m.entry_date order by m.entry_date, m.line_id) filter (where m.side = 'debit') as d_at,
           array_agg(m.line_id order by m.entry_date, m.line_id) filter (where m.side = 'credit') as c_ids,
           array_agg(m.entry_date order by m.entry_date, m.line_id) filter (where m.side = 'credit') as c_at
    from m
    group by m.party, m.account_id, m.account_type, m.amount_open
    having count(*) filter (where m.side = 'debit') > 0
       and count(*) filter (where m.side = 'credit') > 0
  loop
    -- One of each: the pair is the only one there is, whichever is older.
    if cardinality(g.d_ids) = 1 and cardinality(g.c_ids) = 1 then
      v_out := v_out || jsonb_build_object(
        'debit_line_id', g.d_ids[1], 'credit_line_id', g.c_ids[1], 'contact_id', g.party,
        'account_id', g.account_id, 'amount', g.amount_open, 'evidence', 'unique_amount', 'at', g.d_at[1]);
      continue;
    end if;

    -- Several of one amount: in date order. The invoice is the side the
    -- account owes on — the debit of a receivable, the credit of a payable —
    -- and each is paired with the first settlement dated on or after it that
    -- no older invoice took. A settlement dated before an invoice is never
    -- its pair; one dated before every invoice is never anybody's.
    if g.account_type = 'liability_payable' then
      v_inv := g.c_ids; v_inv_at := g.c_at; v_set := g.d_ids; v_set_at := g.d_at;
    else
      v_inv := g.d_ids; v_inv_at := g.d_at; v_set := g.c_ids; v_set_at := g.c_at;
    end if;

    v_j := 1;
    for v_i in 1..cardinality(v_inv) loop
      while v_j <= cardinality(v_set) and v_set_at[v_j] < v_inv_at[v_i] loop
        v_j := v_j + 1;
      end loop;
      exit when v_j > cardinality(v_set);
      v_out := v_out || jsonb_build_object(
        'debit_line_id',  case when g.account_type = 'liability_payable' then v_set[v_j] else v_inv[v_i] end,
        'credit_line_id', case when g.account_type = 'liability_payable' then v_inv[v_i] else v_set[v_j] end,
        'contact_id', g.party, 'account_id', g.account_id, 'amount', g.amount_open,
        'evidence', 'recurring_in_date_order',
        'at', case when g.account_type = 'liability_payable' then v_set_at[v_j] else v_inv_at[v_i] end);
      v_j := v_j + 1;
    end loop;
  end loop;

  return query
    select (o->>'debit_line_id')::uuid, (o->>'credit_line_id')::uuid, (o->>'contact_id')::uuid,
           (o->>'account_id')::uuid, (o->>'amount')::numeric, o->>'evidence'
    from jsonb_array_elements(v_out) o
    join contacts ct on ct.id = (o->>'contact_id')::uuid
    order by ct.name, ct.id, (o->>'account_id'), (o->>'at')::date, (o->>'debit_line_id');
end;
$$;

comment on function suggest_sure_pairs(uuid, uuid) is
  'The pairs of open lines that leave nothing to choose, among the lines matchable_lines() reads (of the company, or of one party): a debit and a credit of one counterparty on one account, open for the same amount to the cent, each line in one pair at most. evidence says why, in the order the rules are read, each on what the earlier ones left: same_document (both lines of one document, or the settlement''s entry carries the document''s number or payment reference), reversal (an entry and what undoes it: reversed_entry_id, or a credit note naming the invoice), unique_amount (the one open debit and the one open credit of that amount), recurring_in_date_order (several lines of one amount: the oldest invoice — the debit of a receivable, the credit of a payable — with the first settlement dated on or after it, then the next; a settlement dated before an invoice is never its pair). It writes nothing: reconcile_batch() matches the pairs a person accepts, as one gesture undone by unreconcile_batch().';

revoke execute on function suggest_sure_pairs(uuid, uuid) from public, anon;
grant execute on function suggest_sure_pairs(uuid, uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 4. reconciliation_batches — one gesture, many matchings
-- ---------------------------------------------------------------------------

create table reconciliation_batches (
  id          uuid primary key default gen_random_uuid(),
  company_id  uuid not null references companies(id) on delete cascade,
  pair_count  integer not null,
  amount      numeric not null,
  created_by  uuid default acting_user(),
  created_at  timestamptz not null default now(),
  undone_by   uuid,
  undone_at   timestamptz,
  constraint reconciliation_batches_pairs_named check (pair_count > 0),
  constraint reconciliation_batches_amount_positive check (amount > 0),
  constraint reconciliation_batches_undone_by_somebody
    check ((undone_at is null) = (undone_by is null))
);

comment on table reconciliation_batches is
  'Matchings made in one gesture: reconcile_batch() writes the row and names it on every matching it wrote (reconciliations.batch_id); unreconcile_batch() undoes those still standing and says when and by whom. Written by those two functions alone (decision 0075).';
comment on column reconciliation_batches.pair_count is
  'How many pairs of lines the gesture matched.';
comment on column reconciliation_batches.amount is
  'The total matched, in the company''s currency.';
comment on column reconciliation_batches.created_by is
  'Who matched: the signed-in user, or the person who issued the machine key presented (acting_user()).';
comment on column reconciliation_batches.undone_at is
  'When unreconcile_batch() undid the gesture; null while it stands.';
comment on column reconciliation_batches.undone_by is
  'Who undid it, as acting_user() said.';

create unique index reconciliation_batches_id_company_idx on reconciliation_batches (id, company_id);
create index reconciliation_batches_company_idx on reconciliation_batches (company_id, created_at);

alter table reconciliation_batches enable row level security;

create policy reconciliation_batches_select on reconciliation_batches
  for select using (company_id = any ((select companies_with_capability('entries.read'))::uuid[]));
create policy reconciliation_batches_insert on reconciliation_batches
  for insert with check (company_id = any ((select companies_with_capability('reconcile.write'))::uuid[]));
create policy reconciliation_batches_update on reconciliation_batches
  for update using (company_id = any ((select companies_with_capability('reconcile.write'))::uuid[]))
  with check (company_id = any ((select companies_with_capability('reconcile.write'))::uuid[]));

comment on policy reconciliation_batches_select on reconciliation_batches is
  'Read with the ledger: entries.read.';
comment on policy reconciliation_batches_insert on reconciliation_batches is
  'reconcile.write, which is what matching asks.';
comment on policy reconciliation_batches_update on reconciliation_batches is
  'reconcile.write, which is what undoing a matching asks.';

grant select, insert, update on table reconciliation_batches to authenticated, service_role;

-- Written by the two functions only, under the setting reconcile() raises —
-- the guard of `reconciliations`, said of the gesture. Not on delete: a batch
-- goes with its company and in no other way, and no grant deletes one.
create or replace function reconciliation_batches_guard()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  if is_installer() then
    return new;
  end if;
  if coalesce(current_setting('ekwo.reconciling', true), '') <> 'on' then
    raise exception 'batch_by_reconcile_batch: a batch of matchings is written by reconcile_batch() and undone by unreconcile_batch(), which match and unmatch what it names'
      using errcode = '55006';
  end if;
  if not has_capability(new.company_id, 'reconcile.write') then
    raise exception 'not_allowed: matching in this company needs reconcile.write'
      using errcode = '42501';
  end if;
  return new;
end;
$$;

comment on function reconciliation_batches_guard() is
  'Refuses a batch of matchings written or changed other than by reconcile_batch() and unreconcile_batch(): batch_by_reconcile_batch. They raise ekwo.reconciling around their writes, honoured for a caller holding reconcile.write.';

revoke execute on function reconciliation_batches_guard() from public, anon, authenticated, service_role;

create trigger reconciliation_batches_guard
  before insert or update on reconciliation_batches
  for each row execute function reconciliation_batches_guard();

create trigger reconciliation_batches_audit
  after insert or update on reconciliation_batches
  for each row execute function audit_changes('{"company":"company_id","key":["id"],"action_insert":"matching_batch_made"}');

alter table reconciliations add column batch_id uuid references reconciliation_batches(id);

comment on column reconciliations.batch_id is
  'The gesture that made this matching, when reconcile_batch() made it; unreconcile_batch() undoes every matching that names it (decision 0075).';

create index reconciliations_batch_idx on reconciliations (batch_id) where batch_id is not null;

-- Both references become composite keys with the company (decision 0065).
do $$
begin
  perform scope_references_to_company('public');
end;
$$;

-- A company leaves with the gestures its matchings were made in, before the
-- matchings that name them.
insert into company_archive_registry (table_name, disposition, load_order, via_column, via_table, reason) values
  ('reconciliation_batches', 'exported', 55, null, null, null)
on conflict (table_schema, table_name) do nothing;

-- ---------------------------------------------------------------------------
-- 5. reconcile_batch and unreconcile_batch
-- ---------------------------------------------------------------------------

create or replace function reconcile_batch(p_pairs jsonb)
returns reconciliation_batches
language plpgsql
volatile
security invoker
as $$
declare
  v_uuid    constant text := '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$';
  v_el      jsonb;
  v_n       integer := 0;
  v_x       text;
  v_y       text;
  v_a       uuid[] := '{}';
  v_b       uuid[] := '{}';
  v_all     uuid[];
  v_count   integer;
  v_company uuid;
  v_m       record;
  v_recs    uuid[] := '{}';
  v_total   numeric := 0;
  v_state   text;
  v_msg     text;
  v_batch   reconciliation_batches;
begin
  if p_pairs is null or jsonb_typeof(p_pairs) <> 'array' or jsonb_array_length(p_pairs) = 0 then
    raise exception 'no_pairs_named: a batch names at least one pair of lines, a debit and a credit'
      using errcode = '22023';
  end if;

  for v_el in select value from jsonb_array_elements(p_pairs) loop
    v_n := v_n + 1;
    v_x := null; v_y := null;
    if jsonb_typeof(v_el) = 'object' then
      v_x := v_el->>'debit_line_id';
      v_y := v_el->>'credit_line_id';
    elsif jsonb_typeof(v_el) = 'array' and jsonb_array_length(v_el) = 2 then
      v_x := v_el->>0;
      v_y := v_el->>1;
    end if;
    if v_x is null or v_y is null or v_x !~ v_uuid or v_y !~ v_uuid then
      raise exception 'pair_malformed: pair % is neither {"debit_line_id", "credit_line_id"} nor [line, line], with two line ids', v_n
        using errcode = '22023';
    end if;
    v_a := v_a || v_x::uuid;
    v_b := v_b || v_y::uuid;
  end loop;

  v_all := v_a || v_b;
  if (select count(distinct x) from unnest(v_all) x) <> cardinality(v_all) then
    raise exception 'duplicate_line: each line is in one pair of a batch, once'
      using errcode = '22023';
  end if;

  -- Row level security answers this select: a line of another company is a
  -- line that does not exist.
  if exists (select 1 from unnest(v_all) x(id) left join entry_lines l on l.id = x.id where l.id is null) then
    raise exception 'unknown_line: one of the lines named is not a ledger line you can read'
      using errcode = 'no_data_found';
  end if;

  select count(distinct l.company_id), min(l.company_id::text)::uuid
    into v_count, v_company
  from entry_lines l where l.id = any(v_all);
  if v_count > 1 then
    raise exception 'reconcile_company_mismatch: the pairs of a batch are of one company';
  end if;

  if not is_installer() and not has_capability(v_company, 'reconcile.write') then
    raise exception 'not_allowed: matching in this company needs reconcile.write'
      using errcode = '42501';
  end if;

  -- Each pair through the checks and the writer of `reconcile_many()`. The
  -- first refusal refuses the batch, and says which pair.
  for k in 1..cardinality(v_a) loop
    begin
      select * into v_m from match_lines(array[v_a[k], v_b[k]], null);
    exception when others then
      get stacked diagnostics v_state = returned_sqlstate, v_msg = message_text;
      raise exception '% (pair % of %)', v_msg, k, cardinality(v_a)
        using errcode = v_state;
    end;
    v_recs  := v_recs || v_m.reconciliation_ids;
    v_total := v_total + v_m.amount;
  end loop;

  perform set_config('ekwo.reconciling', 'on', true);
  insert into reconciliation_batches (company_id, pair_count, amount)
  values (v_company, cardinality(v_a), v_total)
  returning * into v_batch;

  update reconciliations r set batch_id = v_batch.id where r.id = any(v_recs);
  perform set_config('ekwo.reconciling', 'off', true);

  return v_batch;
end;
$$;

comment on function reconcile_batch(jsonb) is
  'Matches several pairs of lines in one gesture — the pairs suggest_sure_pairs() gives, or any a person accepts — and records it in reconciliation_batches, named on each matching. p_pairs is a JSON array of {"debit_line_id", "credit_line_id"} objects or of [line, line] arrays. Each pair goes through match_lines(), the checks of reconcile_many(): posted, one company, one reconcilable account, one counterparty, the company''s currency, open, a debit and a credit, equal to the cent. All or nothing: the first refusal refuses the batch, with its name first and the pair it was given for, "(pair k of n)". Refuses before that no_pairs_named, pair_malformed, duplicate_line, unknown_line, reconcile_company_mismatch and not_allowed (reconcile.write). Returns the batch; unreconcile_batch() undoes it.';

revoke execute on function reconcile_batch(jsonb) from public, anon;
grant execute on function reconcile_batch(jsonb) to authenticated, service_role;

create or replace function unreconcile_batch(p_batch_id uuid)
returns reconciliation_batches
language plpgsql
volatile
security invoker
as $$
declare
  v_batch reconciliation_batches;
  v_id    uuid;
begin
  -- Row level security answers this select: a batch of another company is a
  -- batch that does not exist.
  select * into v_batch from reconciliation_batches b where b.id = p_batch_id;
  if not found then
    raise exception 'unknown_batch: % is not a batch of matchings you can read', p_batch_id
      using errcode = 'no_data_found';
  end if;

  if not is_installer() and not has_capability(v_batch.company_id, 'reconcile.write') then
    raise exception 'not_allowed: undoing a matching in this company needs reconcile.write'
      using errcode = '42501';
  end if;

  if v_batch.undone_at is not null then
    raise exception 'batch_already_undone: batch % was undone at %', p_batch_id, v_batch.undone_at
      using errcode = '55006';
  end if;

  -- The matchings still standing, the last written first, each through the
  -- one function that removes a matching and what it booked. One unmatched
  -- by hand since is simply no longer there.
  for v_id in
    select r.id from reconciliations r
     where r.batch_id = p_batch_id
     order by r.created_at desc, r.id desc
  loop
    if exists (select 1 from reconciliations r where r.id = v_id) then
      perform unreconcile(v_id);
    end if;
  end loop;

  perform set_config('ekwo.reconciling', 'on', true);
  update reconciliation_batches b
     set undone_at = now(), undone_by = acting_user()
   where b.id = p_batch_id
  returning * into v_batch;
  perform set_config('ekwo.reconciling', 'off', true);

  return v_batch;
end;
$$;

comment on function unreconcile_batch(uuid) is
  'Undoes a gesture of reconcile_batch(): every matching of the batch still standing goes through unreconcile(), the last written first, and the batch records when and by whom. Refuses unknown_batch (a batch of another company is one that does not exist), not_allowed (reconcile.write) and batch_already_undone. All or nothing, as the batch was.';

revoke execute on function unreconcile_batch(uuid) from public, anon;
grant execute on function unreconcile_batch(uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 6. match_reversal — `20260919090000`, one counterparty a pair
-- ---------------------------------------------------------------------------

create or replace function match_reversal(p_entry_id uuid, p_reversal_id uuid)
returns integer
language plpgsql
as $$
declare
  v_line    uuid;
  v_mirror  uuid;
  v_matched integer := 0;
begin
  if not exists (
    select 1
      from entries r
      join entries o on o.id = p_entry_id
      left join documents rd on rd.entry_id = r.id
      left join documents od on od.entry_id = o.id
     where r.id = p_reversal_id
       and r.state = 'posted' and o.state = 'posted'
       and (r.reversed_entry_id = o.id
            or (rd.reversed_document_id is not null and rd.reversed_document_id = od.id))
  ) then
    raise exception 'not_a_reversal: entry % does not name entry % as what it undoes, or one of the two is not posted',
      p_reversal_id, p_entry_id;
  end if;

  -- Which lines are reconcilable is read in the chart, under the caller's
  -- policies. A caller who cannot see the account of a line would find no pair
  -- and leave both open without a word, so that is refused instead.
  if exists (
    select 1 from entry_lines l
     where l.entry_id in (p_entry_id, p_reversal_id)
       and not exists (select 1 from accounts a where a.id = l.account_id)
  ) then
    raise exception 'not_allowed: matching entry % with its reversal reads which of its accounts are reconcilable, which needs settings.read',
      p_entry_id
      using errcode = '42501';
  end if;

  -- One pair at a time, read again after every matching: `reconcile()` writes
  -- what is left open on both lines, and the next pair is what is still open.
  -- Never two counterparties: a credit note written by hand may name the
  -- invoice of one customer for another, and that is a question, not a pair.
  loop
    select o.id, m.id
      into v_line, v_mirror
      from entry_lines o
      join accounts a on a.id = o.account_id and a.reconcilable
      join entry_lines m
        on m.entry_id = p_reversal_id
       and m.account_id = o.account_id
       and (m.debit > 0) <> (o.debit > 0)
       and abs(m.debit - m.credit) > m.matched_amount
       and (m.contact_id is null or o.contact_id is null
            or commercial_entity(m.contact_id) = commercial_entity(o.contact_id))
     where o.entry_id = p_entry_id
       and abs(o.debit - o.credit) > o.matched_amount
     order by o.sequence, (m.contact_id is not distinct from o.contact_id) desc, m.sequence
     limit 1;
    exit when not found;

    perform reconcile(v_line, v_mirror);
    v_matched := v_matched + 1;
  end loop;

  return v_matched;
end;
$$;

comment on function match_reversal(uuid, uuid) is
  'Matches every reconcilable line of a posted entry against the line of its posted reversal — or of the credit note of its document — on the same account, the other side and the same counterparty, through reconcile(). Returns how many matchings it made. Called by reverse_entry() and cancel_document(), and as a reversal or a credit note is posted (decision 0075).';

-- ---------------------------------------------------------------------------
-- 7. Matched as it is posted
-- ---------------------------------------------------------------------------

-- Whether the caller may match what a posting undoes: `reconcile.write`, and
-- `settings.read`, where reconcilable is written. One who may not posts as
-- before and leaves the two open for somebody who may.
create or replace function may_match_on_posting(p_company_id uuid)
returns boolean
language sql
stable
security invoker
as $$
  select is_installer()
      or (has_capability(p_company_id, 'reconcile.write')
          and has_capability(p_company_id, 'settings.read'));
$$;

comment on function may_match_on_posting(uuid) is
  'Whether a posting matches what it undoes on the spot: the caller holds reconcile.write and settings.read in the company, or is the installer. Read by the triggers of decision 0075.';

revoke execute on function may_match_on_posting(uuid) from public, anon;
grant execute on function may_match_on_posting(uuid) to authenticated, service_role;

create or replace function entries_match_reversal_on_posting()
returns trigger
language plpgsql
as $$
begin
  if exists (select 1 from entries o where o.id = new.reversed_entry_id and o.state = 'posted')
     and may_match_on_posting(new.company_id) then
    perform match_reversal(new.reversed_entry_id, new.id);
  end if;
  return null;
end;
$$;

comment on function entries_match_reversal_on_posting() is
  'As an entry that names what it undoes (reversed_entry_id) is posted, matches its third-party lines with that entry''s through match_reversal(), when the caller may match (may_match_on_posting()). Whatever wrote the reversal: reverse_entry(), a draft keyed by hand, the mirror unreconcile() posts (decision 0075).';

revoke execute on function entries_match_reversal_on_posting() from public, anon, authenticated, service_role;

create trigger entries_match_reversal_on_posting
  after update of state on entries
  for each row
  when (new.state = 'posted' and old.state is distinct from 'posted' and new.reversed_entry_id is not null)
  execute function entries_match_reversal_on_posting();

create or replace function documents_match_credit_note_on_posting()
returns trigger
language plpgsql
as $$
declare
  v_invoice uuid;
begin
  -- The invoice the credit note names, posted, of the matching kind, in the
  -- same currency at the same rate: then the two ledgers meet to the cent and
  -- the matching books no exchange difference nobody asked for. Row level
  -- security answers the read.
  select i.entry_id into v_invoice
    from documents i
   where i.id = new.reversed_document_id
     and i.state = 'posted'
     and i.entry_id is not null
     and i.doc_type = case new.doc_type
                        when 'sale_credit_note' then 'sale_invoice'
                        when 'purchase_credit_note' then 'purchase_invoice'
                      end::doc_type
     and i.currency_code = new.currency_code
     and i.exchange_rate is not distinct from new.exchange_rate;

  if v_invoice is not null and may_match_on_posting(new.company_id) then
    perform match_reversal(v_invoice, new.entry_id);
  end if;
  return null;
end;
$$;

comment on function documents_match_credit_note_on_posting() is
  'As a credit note that names its invoice (reversed_document_id) is posted, matches its third-party lines with the invoice''s through match_reversal() — for what both still have open, so a credit note for part of an invoice settles that part — when the invoice is posted, of the matching kind, in the same currency at the same rate, and the caller may match (may_match_on_posting()). Decision 0075.';

revoke execute on function documents_match_credit_note_on_posting() from public, anon, authenticated, service_role;

create trigger documents_match_credit_note_on_posting
  after update of state on documents
  for each row
  when (new.state = 'posted' and old.state = 'draft'
        and new.reversed_document_id is not null
        and new.doc_type in ('sale_credit_note', 'purchase_credit_note'))
  execute function documents_match_credit_note_on_posting();

-- ---------------------------------------------------------------------------
-- 8. unreconcile — `20261018210000`, with its mirrors matched as posted
-- ---------------------------------------------------------------------------

create or replace function unreconcile(p_reconciliation_id uuid)
returns void
language plpgsql
as $$
declare
  v_row     reconciliations%rowtype;
  v_date    date;
  v_fx      entries%rowtype;
  v_mirror  entries%rowtype;
  v_adj     entries%rowtype;
  v_doc     uuid;
  v_line    uuid;
  v_back    uuid;
  fl        record;
begin
  select * into v_row from reconciliations where id = p_reconciliation_id;
  if not found then
    raise exception 'unknown_reconciliation: %', p_reconciliation_id;
  end if;

  select greatest(ed.entry_date, ec.entry_date) into v_date
    from entry_lines ld join entries ed on ed.id = ld.entry_id,
         entry_lines lc join entries ec on ec.id = lc.entry_id
   where ld.id = v_row.debit_line_id and lc.id = v_row.credit_line_id;

  perform set_config('ekwo.reconciling', 'on', true);
  delete from reconciliations where id = p_reconciliation_id;

  -- An exchange difference was realised by this matching and by nothing else,
  -- so undoing the matching takes it back: its own matching goes, and a mirror
  -- entry cancels it on the same date. The period has to be open, which is the
  -- honest refusal — a difference that has been declared is not unmade quietly.
  -- The mirror is matched with it as it is posted (decision 0075).
  if v_row.fx_entry_id is not null then
    select * into v_fx from entries where id = v_row.fx_entry_id;

    delete from reconciliations r
     where r.company_id = v_row.company_id
       and (r.debit_line_id in (select id from entry_lines where entry_id = v_fx.id)
         or r.credit_line_id in (select id from entry_lines where entry_id = v_fx.id));

    insert into entries (company_id, journal_id, fiscal_year_id, entry_date,
                         description, state, currency_code, reversed_entry_id)
    values (v_fx.company_id, v_fx.journal_id, v_fx.fiscal_year_id, v_fx.entry_date,
            'Exchange difference undone', 'draft', v_fx.currency_code, v_fx.id)
    returning * into v_mirror;

    for fl in select * from entry_lines where entry_id = v_fx.id order by sequence loop
      insert into entry_lines (entry_id, company_id, account_id, sequence, name,
                               debit, credit, contact_id, currency_code)
      values (v_mirror.id, fl.company_id, fl.account_id, fl.sequence, fl.name,
              fl.credit, fl.debit, fl.contact_id, fl.currency_code);
    end loop;

    perform post_entry(v_mirror.id);
    -- The matching of the mirror lowered the setting when it was done.
    perform set_config('ekwo.reconciling', 'on', true);
  end if;

  -- A difference booked by reconcile_with_difference() goes the same way:
  -- every matching of its line, then its mirror, and the line matched with
  -- the mirror's so that neither is left open (decision 0072) — as the mirror
  -- is posted, and here for a caller the posting did not match for.
  if v_row.adjustment_entry_id is not null then
    select * into v_adj from entries where id = v_row.adjustment_entry_id;

    delete from reconciliations r
     where r.company_id = v_row.company_id
       and (r.debit_line_id in (select id from entry_lines where entry_id = v_adj.id)
         or r.credit_line_id in (select id from entry_lines where entry_id = v_adj.id));

    insert into entries (company_id, journal_id, fiscal_year_id, entry_date,
                         description, state, currency_code, reversed_entry_id)
    values (v_adj.company_id, v_adj.journal_id, v_adj.fiscal_year_id, v_adj.entry_date,
            'Difference on matching undone', 'draft', v_adj.currency_code, v_adj.id)
    returning * into v_mirror;

    for fl in select * from entry_lines where entry_id = v_adj.id order by sequence loop
      insert into entry_lines (entry_id, company_id, account_id, sequence, name,
                               debit, credit, contact_id, currency_code)
      values (v_mirror.id, fl.company_id, fl.account_id, fl.sequence, fl.name,
              fl.credit, fl.debit, fl.contact_id, fl.currency_code);
    end loop;

    perform post_entry(v_mirror.id);
    perform set_config('ekwo.reconciling', 'on', true);

    select l.id into v_line
      from entry_lines l join accounts a on a.id = l.account_id
     where l.entry_id = v_adj.id and a.reconcilable
       and abs(l.debit - l.credit) > l.matched_amount;
    select l.id into v_back
      from entry_lines l join accounts a on a.id = l.account_id
     where l.entry_id = v_mirror.id and a.reconcilable
       and abs(l.debit - l.credit) > l.matched_amount;
  end if;

  -- The share of a cash-basis tax that is due has just fallen; the same
  -- function books the difference, which is now the other way round.
  for v_doc in
    select distinct d.id
      from entry_lines l join documents d on d.entry_id = l.entry_id
     where l.id in (v_row.debit_line_id, v_row.credit_line_id)
  loop
    perform settle_cash_basis_tax(v_doc, v_date);
  end loop;

  -- Last, because reconcile() lowers the setting when it is done.
  if v_line is not null and v_back is not null then
    perform reconcile(v_line, v_back);
  end if;

  perform set_config('ekwo.reconciling', 'off', true);
end;
$$;

comment on function unreconcile(uuid) is
  'Undoes a matching, and with it what the matching had booked: the exchange difference it realised (its mirror is posted and matched with it), the difference reconcile_with_difference() booked (every matching of its line goes, its mirror is posted and the two lines are matched together), and the share of a cash-basis tax it had made due. The one way a matching is removed; unreconcile_batch() calls it for each matching of a batch.';

revoke execute on function unreconcile(uuid) from public, anon;
grant execute on function unreconcile(uuid) to authenticated, service_role;
