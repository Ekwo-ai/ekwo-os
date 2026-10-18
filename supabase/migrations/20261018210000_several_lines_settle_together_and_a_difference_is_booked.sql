-- Ekwo OS — several lines settle together, and a small difference is booked
-- (decision 0071).
--
-- A matching screen over the receivable and payable accounts meets three
-- shapes `reconcile()` does not answer in one gesture:
--
--   * one payment that settles three invoices of one customer, or one invoice
--     paid in three instalments — several lines against several, the totals
--     equal to the cent;
--   * a pair that differs by a little — a payment of 97.00 for an invoice of
--     100.00, the bank having kept 3.00 — that a person looks at, gives a
--     reason for, and closes;
--   * and the proposals behind both, which have to come from the search that
--     already proposes several invoices for one bank line, not a second one.
--
-- **One search.** `suggest_combination()` walked one counterparty's open items
-- oldest first and greedily. Its walk becomes `combination_subsets()`: the
-- same order and the same rule for taking an item — no more than what is left
-- plus the tolerance — made a bounded depth-first search, so the first answer
-- it gives is the greedy answer whenever the greedy walk had one, and it finds
-- the subsets the greedy walk stepped over. The bounds are in one place,
-- `matching_search_bounds()`: 40 candidates, 10 lines in a subset, 20 000
-- steps of the walk, 3 proposals for a line. `suggest_combination()` asks it
-- for a statement line, `suggest_item_combinations()` for a ledger line.
--
-- **Several lines in one call.** `reconcile_many(lines)` checks the set —
-- posted, one company, one reconcilable account, one counterparty, the
-- company's currency, something open on each, a debit and a credit, and the
-- totals equal — then pairs the debits and the credits oldest first through
-- `reconcile()`, which stays the one writer of a matching, draws or merges
-- the letter and books the tax a cash basis makes due.
--
-- **A difference is booked, never forgiven.** `reconcile_with_difference(lines,
-- reason)` takes the same set with totals that differ by no more than the
-- company's `difference_tolerance_units`, posts an entry that books the
-- difference on the third-party account — same account, same counterparty —
-- against the account the pack gives for the reason, and matches everything
-- under one letter. The reasons are the roles the packs carry: `rounding`
-- (`defaults.roles.rounding`, the company's rounding account) and
-- `exchange_difference` (`fx_gain` / `fx_loss`, by the sign of the
-- difference). No pack names an account for bank charges or for a payment
-- discount, so neither is offered: a reason with no account is refused rather
-- than booked on a neighbour. `matching_difference_reasons()` and
-- `matching_difference_tolerance()` tell a screen what it may propose.
--
-- **The tolerance is its own setting.** `amount_tolerance_units` decides what
-- `auto_settle()` applies on its own; raising it to let a person close a pair
-- 3.00 apart would let the machine settle 97.00 against 100.00 without
-- anybody. A difference a person books has its own number, counted in units
-- of the currency like the others, 500 when the company has no opinion.
--
-- **Undoing takes back what was booked.** `reconciliations.adjustment_entry_id`
-- names the entry on the matchings of its line, and `unreconcile()` of one of
-- them removes every matching of that line, posts the mirror of the entry and
-- matches the line with its mirror, so neither stays open.

-- ---------------------------------------------------------------------------
-- 1. The tolerance of a difference a person books
-- ---------------------------------------------------------------------------

alter table matching_settings
  add column difference_tolerance_units integer check (difference_tolerance_units >= 0);

comment on column matching_settings.difference_tolerance_units is
  'How many smallest units of the currency a set of lines may be apart and still be closed by reconcile_with_difference(), which books the difference. Its own number: amount_tolerance_units decides what is applied without anybody.';

alter type matching_policy add attribute difference_tolerance_units integer;

comment on type matching_policy is
  'The six numbers the matching runs on, resolved for one company.';

create or replace function matching_policy_of(p_company_id uuid)
returns matching_policy
language sql
stable
security invoker
set search_path = public
as $$
  -- The shipped answers, in the one place they exist. Each comes from rules
  -- that have run in production; none is a fact about a country, a currency or
  -- a language, which is why they can be shipped at all.
  --
  --   0.600  a name is evidence at three fifths of agreement
  --   1      one smallest unit of the currency between two amounts
  --   2      two of them across a sum of documents rounded separately
  --   90     a payment more than a quarter away from its document is a
  --          question, not a match
  --   4      a word of three letters or fewer is a legal form or a
  --          preposition, never a party
  --   500    a difference a person books and matches: a charge kept back, a
  --          rounding, an exchange difference — not a debt forgiven
  select row(
    coalesce(s.name_threshold,             0.600),
    coalesce(s.amount_tolerance_units,     1),
    coalesce(s.sum_tolerance_units,        2),
    coalesce(s.date_window_days,           90),
    coalesce(s.minimum_word_length,        4),
    coalesce(s.difference_tolerance_units, 500)
  )::matching_policy
  from (select p_company_id as company_id) c
  left join matching_settings s on s.company_id = c.company_id;
$$;

comment on function matching_policy_of(uuid) is
  'The six numbers, for this company: its own where it has an opinion, the shipped ones otherwise. The only function that carries a default.';

revoke execute on function matching_policy_of(uuid) from public, anon;
grant execute on function matching_policy_of(uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 2. The search, once
-- ---------------------------------------------------------------------------

create or replace function matching_search_bounds()
returns table (
  max_candidates integer,
  max_lines      integer,
  max_steps      integer,
  max_proposals  integer
)
language sql
immutable
as $$
  -- 40   open items considered for one line: the oldest in the window for a
  --      statement line, the nearest in date for a ledger line
  -- 10   lines in one subset: a month of invoices paid in one wire
  -- 20000 steps of the walk, after which it stops with what it found
  -- 3    proposals for one line: more is a list nobody reads
  select 40, 10, 20000, 3;
$$;

comment on function matching_search_bounds() is
  'The bounds of the search for several open items that settle one line, in the one place they are written: how many candidates, how many lines in a subset, how many steps of the walk, how many proposals for a line. Read by combination_subsets(), suggest_combination() and suggest_item_combinations().';

revoke execute on function matching_search_bounds() from public, anon;
grant execute on function matching_search_bounds() to authenticated, service_role;

create or replace function combination_subsets(
  p_amounts     numeric[],
  p_target      numeric,
  p_tolerance   numeric default 0,
  p_min_lines   integer default 2,
  p_max_results integer default 1
)
returns setof integer[]
language plpgsql
immutable
as $$
declare
  v_bounds record;
  v_n      integer := coalesce(cardinality(p_amounts), 0);
  v_rest   numeric[];
  v_pick   integer[] := '{}';
  v_sum    numeric := 0;
  v_i      integer := 1;
  v_last   integer;
  v_steps  integer := 0;
  v_found  integer := 0;
begin
  if v_n = 0 or p_target is null or p_target <= 0 or coalesce(p_max_results, 0) <= 0 then
    return;
  end if;
  if exists (select 1 from unnest(p_amounts) a where a is null or a <= 0) then
    raise exception 'combination_amount_not_positive: every amount searched is more than nothing'
      using errcode = '22023';
  end if;
  select * into v_bounds from matching_search_bounds();

  -- What is left from each position on: a branch that cannot reach the
  -- target with everything after it is not walked.
  v_rest := array_fill(0::numeric, array[v_n + 1]);
  for k in reverse v_n..1 loop
    v_rest[k] := v_rest[k + 1] + p_amounts[k];
  end loop;

  -- In the order given, an item is taken when it is no more than what is
  -- left plus the tolerance, and left otherwise — the greedy walk of
  -- `20260917120000`, which is therefore the first path tried. Coming back
  -- up, the last item taken is left out and the walk goes on after it.
  loop
    v_steps := v_steps + 1;
    exit when v_steps > v_bounds.max_steps;

    if v_i <= v_n
       and cardinality(v_pick) < v_bounds.max_lines
       and v_sum + v_rest[v_i] >= p_target - p_tolerance then
      if p_amounts[v_i] <= p_target - v_sum + p_tolerance then
        v_pick := v_pick || v_i;
        v_sum  := v_sum + p_amounts[v_i];
        if abs(p_target - v_sum) <= p_tolerance then
          if cardinality(v_pick) >= p_min_lines then
            return next v_pick;
            v_found := v_found + 1;
            exit when v_found >= p_max_results;
          end if;
          -- A subset that reaches the target is not made longer.
          v_pick := v_pick[1:cardinality(v_pick) - 1];
          v_sum  := v_sum - p_amounts[v_i];
        end if;
      end if;
      v_i := v_i + 1;
    else
      exit when cardinality(v_pick) = 0;
      v_last := v_pick[cardinality(v_pick)];
      v_pick := v_pick[1:cardinality(v_pick) - 1];
      v_sum  := v_sum - p_amounts[v_last];
      v_i    := v_last + 1;
    end if;
  end loop;
end;
$$;

comment on function combination_subsets(numeric[], numeric, numeric, integer, integer) is
  'The subsets of a list of positive amounts that add up to a target within a tolerance, as positions in the list, in the order a depth-first walk meets them: an item is taken when it is no more than what is left plus the tolerance, so the first subset is the one an oldest-first greedy walk finds when it finds one. At least p_min_lines positions each, at most p_max_results subsets, within matching_search_bounds(). Pure arithmetic: it reads no table.';

revoke execute on function combination_subsets(numeric[], numeric, numeric, integer, integer) from public, anon;
grant execute on function combination_subsets(numeric[], numeric, numeric, integer, integer) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 3. suggest_combination — `20260917120000`, through the one search
-- ---------------------------------------------------------------------------

create or replace function suggest_combination(p_transaction_id uuid)
returns table (
  line_ids uuid[],
  amount   numeric,
  because  text
)
language plpgsql
stable
security invoker
as $$
declare
  v_tx        bank_transactions;
  v_policy    matching_policy;
  v_round     money_rounding;
  v_tolerance numeric;
  v_side      text;
  v_home      char(3);
  v_bounds    record;
  v_ids       uuid[];
  v_amounts   numeric[];
  v_subset    integer[];
begin
  select * into v_tx from bank_transactions t where t.id = p_transaction_id;
  if not found then
    raise exception 'not_found: bank transaction %', p_transaction_id
      using errcode = 'no_data_found';
  end if;

  -- Without a counterparty the search space is every open item of the company,
  -- and a sum that reaches the right total across unrelated customers is
  -- arithmetic, not evidence.
  if v_tx.contact_id is null then return; end if;

  select c.currency_code into v_home from companies c where c.id = v_tx.company_id;
  if v_tx.currency_code <> v_home then return; end if;

  v_policy    := matching_policy_of(v_tx.company_id);
  v_round     := rounding_of(v_tx.company_id, v_tx.currency_code);
  -- Each document was rounded on its own, so a sum of them may miss by more
  -- than one unit. Two, by default, and the company may say otherwise.
  v_tolerance := v_policy.sum_tolerance_units * power(10::numeric, -v_round.decimals);
  v_side      := case when v_tx.amount > 0 then 'debit' else 'credit' end;
  select * into v_bounds from matching_search_bounds();

  select array_agg(c.line_id order by c.entry_date, c.line_id),
         array_agg(c.amount_open order by c.entry_date, c.line_id)
    into v_ids, v_amounts
  from (
    select i.line_id, i.amount_open, i.entry_date
    from open_items(v_tx.company_id, v_tx.contact_id) i
    where i.side = v_side
      and abs(i.entry_date - v_tx.transaction_date) <= v_policy.date_window_days
    order by i.entry_date, i.line_id
    limit v_bounds.max_candidates
  ) c;

  select s into v_subset
  from combination_subsets(v_amounts, abs(v_tx.amount), v_tolerance, 2, 1) s;

  if v_subset is not null then
    return query
      select array(select v_ids[k] from unnest(v_subset) with ordinality u(k, n) order by n),
             (select sum(v_amounts[k]) from unnest(v_subset) k),
             format('%s open items of this counterparty add up to %s',
                    cardinality(v_subset), (select sum(v_amounts[k]) from unnest(v_subset) k));
  end if;
end;
$$;

comment on function suggest_combination(uuid) is
  'A subset of one counterparty''s open items that adds up to the statement line, found by combination_subsets() over the oldest items of the window — the oldest-first answer when there is one. A proposal only: it is never applied automatically, because a sum that reaches the right total from the wrong documents leaves nothing behind to notice.';

-- ---------------------------------------------------------------------------
-- 4. suggest_item_combinations — the same search, between ledger lines
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
  v_party     uuid;
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
  if p_contact_id is not null then
    v_party := commercial_entity(p_contact_id);
  end if;

  for s in
    with items as (
      -- Open receivable and payable lines that name somebody, in the
      -- company's currency: a branch and its parent are one party, as for
      -- `reconcile()`.
      select i.line_id, i.account_id, i.side, i.amount_open, i.entry_date,
             commercial_entity(i.contact_id) as party
      from open_items(p_company_id, null, null, true) i
      join entry_lines l on l.id = i.line_id
      where i.contact_id is not null
        and (l.currency_code is null or l.currency_code = v_home or coalesce(l.amount_currency, 0) = 0)
    ),
    scoped as (
      select * from items where v_party is null or party = v_party
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
  'What open receivable and payable lines of one counterparty on one account could settle each other — of the company, or of one contact (a branch and its parent are one party). For each open line (line_id), up to three proposals, in this order: one line of the other side for the same amount (kind pair, said once, from the debit), several lines that add up to it to the cent (kind combination, found by combination_subsets()), and only when nothing is exact, a pair then several lines within the company''s difference tolerance (difference, signed: the line less the total). proposal_id is stable for the same lines; alternatives counts the proposals of the line. Lines in another currency than the company''s are not searched. It writes nothing and decides nothing: reconcile_many() and reconcile_with_difference() settle a proposal a person chose.';

revoke execute on function suggest_item_combinations(uuid, uuid) from public, anon;
grant execute on function suggest_item_combinations(uuid, uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 5. What a screen may propose for a difference
-- ---------------------------------------------------------------------------

create or replace function matching_difference_tolerance(p_company_id uuid)
returns table (
  tolerance_units integer,
  tolerance       numeric,
  currency_code   char(3)
)
language plpgsql
stable
security invoker
as $$
declare
  v_home char(3);
begin
  select c.currency_code into v_home from companies c where c.id = p_company_id;
  if v_home is null then return; end if;

  tolerance_units := (matching_policy_of(p_company_id)).difference_tolerance_units;
  tolerance       := tolerance_units * currency_unit(rounding_of(p_company_id));
  currency_code   := v_home;
  return next;
end;
$$;

comment on function matching_difference_tolerance(uuid) is
  'The largest difference reconcile_with_difference() books for this company: in units of the currency (matching_settings.difference_tolerance_units, 500 when the company has no opinion) and as an amount of the company''s currency. No row for a company the caller cannot read.';

revoke execute on function matching_difference_tolerance(uuid) from public, anon;
grant execute on function matching_difference_tolerance(uuid) to authenticated, service_role;

create or replace function matching_difference_reasons(p_company_id uuid)
returns table (
  reason       text,
  side         text,
  account_id   uuid,
  account_code text,
  account_name text,
  available    boolean,
  because      text
)
language sql
stable
security invoker
as $$
  -- The reasons are the roles the packs carry, read for this company: the
  -- rounding account the installer wired from `defaults.roles.rounding`, and
  -- the exchange gain and loss accounts of `fx_gain` and `fx_loss`. `side`
  -- says which difference a row answers: `charge` when the lines settled
  -- carry more debit than credit (the difference is a cost), `income` the
  -- other way, `either` for both.
  with company as (
    select c.id, c.rounding_account_id, c.country from companies c where c.id = p_company_id
  ),
  wanted as (
    select 'rounding'::text as reason, 'either'::text as side, co.rounding_account_id as account_id,
           'the pack names no rounding account, or the company has none' as missing, 1 as n
    from company co
    union all
    select 'exchange_difference', 'charge', account_id_by_code(co.id, cd.fx_loss_code),
           'the pack names no exchange loss account, or the company does not have it', 2
    from company co left join country_defaults cd on cd.country = co.country
    union all
    select 'exchange_difference', 'income', account_id_by_code(co.id, cd.fx_gain_code),
           'the pack names no exchange gain account, or the company does not have it', 3
    from company co left join country_defaults cd on cd.country = co.country
  )
  select w.reason, w.side, a.id, a.code, a.name,
         a.id is not null and not a.deprecated and not a.reconcilable,
         case when a.id is null then w.missing
              when a.deprecated then format('account %s is deprecated', a.code)
              when a.reconcilable then format('account %s is reconcilable, and its line would be an open item', a.code)
              else format('booked on %s %s', a.code, a.name) end
  from wanted w
  left join accounts a on a.id = w.account_id
  order by w.n;
$$;

comment on function matching_difference_reasons(uuid) is
  'The reasons reconcile_with_difference() accepts for this company, each with the account the difference is booked on and whether it can be: rounding (the company''s rounding account, from the pack role rounding) for either side, exchange_difference on the exchange loss account for a charge and on the exchange gain account for an income (pack roles fx_loss and fx_gain). available is false, with the reason in because, where the pack or the company names no usable account. No pack carries a role for bank charges or a payment discount, so neither is a reason. No row for a company the caller cannot read.';

revoke execute on function matching_difference_reasons(uuid) from public, anon;
grant execute on function matching_difference_reasons(uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 6. The entry a difference is booked in, named on its matchings
-- ---------------------------------------------------------------------------

alter table reconciliations add column adjustment_entry_id uuid references entries(id);

comment on column reconciliations.adjustment_entry_id is
  'The entry reconcile_with_difference() posted for the difference, on the matchings of its third-party line. unreconcile() of one of them takes the entry back with its mirror (decision 0071).';

create index reconciliations_adjustment_entry_idx on reconciliations (adjustment_entry_id)
  where adjustment_entry_id is not null;

-- A reference by id alone becomes a composite key with the company, like
-- every other reference of the schema (decision 0065).
do $$
begin
  perform scope_references_to_company('public');
end;
$$;

-- ---------------------------------------------------------------------------
-- 7. match_lines — several lines, and a difference, in one gesture
-- ---------------------------------------------------------------------------

create or replace function match_lines(p_line_ids uuid[], p_reason text default null)
returns table (
  matching_number     text,
  amount              numeric,
  difference          numeric,
  adjustment_entry_id uuid,
  reconciliation_ids  uuid[]
)
language plpgsql
volatile
security invoker
as $$
declare
  v_count     integer;
  v_company   uuid;
  v_account   uuid;
  v_parties   integer;
  v_party     uuid;
  v_home      char(3);
  v_debit     numeric;
  v_credit    numeric;
  v_diff      numeric;
  v_tolerance numeric;
  v_round     money_rounding;
  v_bad       record;
  v_reason_account uuid;
  v_target    accounts;
  v_journal   uuid;
  v_date      date;
  v_entry     entries;
  v_adj_line  uuid;
  v_lines     uuid[];
  v_d_ids     uuid[];
  v_d_open    numeric[];
  v_c_ids     uuid[];
  v_c_open    numeric[];
  v_i         integer := 1;
  v_j         integer := 1;
  v_take      numeric;
  v_rec       reconciliations;
  v_recs      uuid[] := '{}';
  v_letter    text;
begin
  if p_line_ids is null or cardinality(p_line_ids) < 2 then
    raise exception 'no_lines_named: a matching names at least two lines, a debit and a credit'
      using errcode = '22023';
  end if;
  if (select count(distinct x) from unnest(p_line_ids) x) <> cardinality(p_line_ids)
     or array_position(p_line_ids, null) is not null then
    raise exception 'duplicate_line: each line is named once, and none is empty'
      using errcode = '22023';
  end if;
  if p_reason is not null and p_reason not in ('rounding', 'exchange_difference') then
    raise exception 'unknown_difference_reason: % is not a reason; matching_difference_reasons() lists rounding and exchange_difference with their accounts',
      p_reason
      using errcode = '22023';
  end if;

  -- Row level security answers this select: a line of another company is a
  -- line that does not exist.
  select l.id into v_bad
  from unnest(p_line_ids) x(id)
  left join entry_lines l on l.id = x.id
  where l.id is null
  limit 1;
  if found then
    raise exception 'unknown_line: one of the lines named is not a ledger line you can read'
      using errcode = 'no_data_found';
  end if;

  select count(distinct l.company_id), min(l.company_id::text)::uuid
    into v_count, v_company
  from entry_lines l where l.id = any(p_line_ids);
  if v_count > 1 then
    raise exception 'reconcile_company_mismatch: lines belong to different companies';
  end if;

  if not is_installer() and not has_capability(v_company, 'reconcile.write') then
    raise exception 'not_allowed: matching in this company needs reconcile.write'
      using errcode = '42501';
  end if;

  select l.id, e.state into v_bad
  from entry_lines l join entries e on e.id = l.entry_id
  where l.id = any(p_line_ids) and e.state <> 'posted'
  limit 1;
  if found then
    raise exception 'line_not_posted: line % belongs to an entry that is %; only posted lines are matched',
      v_bad.id, v_bad.state
      using errcode = '55006';
  end if;

  select count(distinct l.account_id), min(l.account_id::text)::uuid
    into v_count, v_account
  from entry_lines l where l.id = any(p_line_ids);
  if v_count > 1 then
    raise exception 'reconcile_account_mismatch: lines are on different accounts';
  end if;
  if not exists (select 1 from accounts a where a.id = v_account and a.reconcilable) then
    raise exception 'account_not_reconcilable: the account of these lines is not reconcilable';
  end if;

  -- One counterparty: a branch and its parent are one party, and a line that
  -- names nobody is attributed by the matching — `reconcile()`'s rule.
  select count(distinct commercial_entity(l.contact_id)),
         min(commercial_entity(l.contact_id)::text)::uuid
    into v_parties, v_party
  from entry_lines l where l.id = any(p_line_ids) and l.contact_id is not null;
  if v_parties > 1 then
    raise exception 'reconcile_contact_mismatch: the lines name % different counterparties, and a matching settles the items of one',
      v_parties;
  end if;

  select c.currency_code into v_home from companies c where c.id = v_company;
  select l.id into v_bad
  from entry_lines l
  where l.id = any(p_line_ids)
    and l.currency_code is not null and l.currency_code <> v_home
    and coalesce(l.amount_currency, 0) <> 0
  limit 1;
  if found then
    raise exception 'reconcile_foreign_currency: line % is stated in another currency than the company''s; match it pair by pair with reconcile(), which books the exchange difference',
      v_bad.id
      using errcode = '0A000';
  end if;

  select l.id into v_bad
  from entry_lines l
  where l.id = any(p_line_ids) and abs(l.balance) - l.matched_amount <= 0
  limit 1;
  if found then
    raise exception 'line_not_open: line % has nothing left open', v_bad.id
      using errcode = '55006';
  end if;

  select coalesce(sum(abs(l.balance) - l.matched_amount) filter (where l.debit > 0), 0),
         coalesce(sum(abs(l.balance) - l.matched_amount) filter (where l.debit = 0), 0)
    into v_debit, v_credit
  from entry_lines l where l.id = any(p_line_ids);
  if v_debit = 0 or v_credit = 0 then
    raise exception 'reconcile_same_side: a debit must be matched against a credit';
  end if;

  v_diff := v_debit - v_credit;

  if p_reason is null then
    if v_diff <> 0 then
      raise exception 'reconcile_unbalanced: the debits leave % open and the credits %; off by %. reconcile_with_difference() books a small difference with its reason',
        v_debit, v_credit, v_diff
        using errcode = '23514';
    end if;
  else
    if v_diff = 0 then
      raise exception 'no_difference: the debits and the credits are both %; reconcile_many() matches them', v_debit
        using errcode = '22023';
    end if;
    v_round     := rounding_of(v_company);
    v_tolerance := (matching_policy_of(v_company)).difference_tolerance_units * currency_unit(v_round);
    if abs(v_diff) > v_tolerance then
      raise exception 'difference_above_tolerance: the lines are % apart and the company books a difference of at most %',
        abs(v_diff), v_tolerance
        using errcode = '23514';
    end if;

    -- The account the pack gives for the reason, on the side the difference
    -- falls: more debit than credit is a cost, the other way an income.
    select r.account_id into v_reason_account
    from matching_difference_reasons(v_company) r
    where r.reason = p_reason
      and r.side in ('either', case when v_diff > 0 then 'charge' else 'income' end)
    limit 1;
    if v_reason_account is null then
      raise exception 'no_account_for_reason: the pack names no account for % on a %, or the company does not have it',
        p_reason, case when v_diff > 0 then 'charge' else 'income' end
        using errcode = '55000';
    end if;
    select * into v_target from accounts a where a.id = v_reason_account;
    if v_target.deprecated or v_target.reconcilable or v_target.account_type = 'off_balance' then
      raise exception 'account_takes_no_entries: account % is %; a difference is booked on an account that takes a charge or an income',
        v_target.code,
        case when v_target.deprecated then 'deprecated'
             when v_target.account_type = 'off_balance' then 'off the balance sheet'
             else 'reconcilable, and its line would be an open item nothing settles' end;
    end if;

    select c.miscellaneous_journal_id into v_journal from companies c where c.id = v_company;
    if v_journal is null then
      raise exception 'no_miscellaneous_journal: company % has no journal for a difference', v_company;
    end if;

    -- On the day the settlement is complete: the latest of the lines.
    select max(e.entry_date) into v_date
    from entry_lines l join entries e on e.id = l.entry_id
    where l.id = any(p_line_ids);

    insert into entries (company_id, journal_id, fiscal_year_id, entry_date,
                         description, state, currency_code)
    values (v_company, v_journal, fiscal_year_at(v_company, v_date), v_date,
            'Difference on matching (' || replace(p_reason, '_', ' ') || ')', 'draft', v_home)
    returning * into v_entry;

    -- The third-party side closes what is left: a credit when the debits
    -- were more, a debit otherwise, on the same account and counterparty.
    insert into entry_lines (entry_id, company_id, account_id, sequence, name,
                             debit, credit, contact_id, currency_code)
    values (v_entry.id, v_company, v_account, 10,
            'Difference on matching',
            case when v_diff < 0 then abs(v_diff) else 0 end,
            case when v_diff > 0 then abs(v_diff) else 0 end,
            v_party, v_home)
    returning id into v_adj_line;

    insert into entry_lines (entry_id, company_id, account_id, sequence, name,
                             debit, credit, currency_code)
    values (v_entry.id, v_company, v_reason_account, 20,
            'Difference on matching',
            case when v_diff > 0 then abs(v_diff) else 0 end,
            case when v_diff < 0 then abs(v_diff) else 0 end,
            v_home);

    v_entry := post_entry(v_entry.id);
  end if;

  -- The debits against the credits, oldest first on both sides, each pair
  -- for what both still have open. The totals are equal, so the walk ends
  -- with nothing open on either side.
  v_lines := p_line_ids || case when v_adj_line is null then '{}'::uuid[] else array[v_adj_line] end;

  select array_agg(l.id order by e.entry_date, l.id),
         array_agg(abs(l.balance) - l.matched_amount order by e.entry_date, l.id)
    into v_d_ids, v_d_open
  from entry_lines l join entries e on e.id = l.entry_id
  where l.id = any(v_lines) and l.debit > 0;

  select array_agg(l.id order by e.entry_date, l.id),
         array_agg(abs(l.balance) - l.matched_amount order by e.entry_date, l.id)
    into v_c_ids, v_c_open
  from entry_lines l join entries e on e.id = l.entry_id
  where l.id = any(v_lines) and l.debit = 0;

  while v_i <= cardinality(v_d_ids) and v_j <= cardinality(v_c_ids) loop
    v_take := least(v_d_open[v_i], v_c_open[v_j]);
    v_rec  := reconcile(v_d_ids[v_i], v_c_ids[v_j], v_take);
    v_recs := v_recs || v_rec.id;
    v_d_open[v_i] := v_d_open[v_i] - v_take;
    v_c_open[v_j] := v_c_open[v_j] - v_take;
    if v_d_open[v_i] = 0 then v_i := v_i + 1; end if;
    if v_c_open[v_j] = 0 then v_j := v_j + 1; end if;
  end loop;

  -- The entry of the difference, named on the matchings of its line, under
  -- the setting the guard of `reconciliations` honours.
  if v_adj_line is not null then
    perform set_config('ekwo.reconciling', 'on', true);
    update reconciliations r
       set adjustment_entry_id = v_entry.id
     where r.id = any(v_recs)
       and (r.debit_line_id = v_adj_line or r.credit_line_id = v_adj_line);
    perform set_config('ekwo.reconciling', 'off', true);
  end if;

  -- Merging two chains may have renamed the letter on the way: the last one
  -- written carries the letter all of them now share.
  select r.matching_number into v_letter from reconciliations r where r.id = v_recs[cardinality(v_recs)];

  matching_number     := v_letter;
  amount              := greatest(v_debit, v_credit);
  difference          := v_diff;
  adjustment_entry_id := v_entry.id;
  reconciliation_ids  := v_recs;
  return next;
end;
$$;

comment on function match_lines(uuid[], text) is
  'The one implementation of reconcile_many() and reconcile_with_difference(): checks the set of lines, books the difference when a reason is given, and pairs the debits with the credits oldest first through reconcile(). Call those two rather than this.';

revoke execute on function match_lines(uuid[], text) from public, anon;
grant execute on function match_lines(uuid[], text) to authenticated, service_role;

create or replace function reconcile_many(p_line_ids uuid[])
returns table (
  matching_number     text,
  amount              numeric,
  difference          numeric,
  adjustment_entry_id uuid,
  reconciliation_ids  uuid[]
)
language sql
volatile
security invoker
as $$
  select * from match_lines(p_line_ids, null);
$$;

comment on function reconcile_many(uuid[]) is
  'Matches several lines together — one payment against three invoices, one invoice against three instalments — when their open debits and credits are equal to the cent: posted lines of one company, on one reconcilable account, of one counterparty (a line naming nobody is attributed by the matching), in the company''s currency, each with something open. Pairs them oldest first through reconcile(), under one letter. Refuses by name: no_lines_named, duplicate_line, unknown_line, reconcile_company_mismatch, not_allowed (reconcile.write), line_not_posted, reconcile_account_mismatch, account_not_reconcilable, reconcile_contact_mismatch, reconcile_foreign_currency, line_not_open, reconcile_same_side, reconcile_unbalanced. Returns the letter, the amount matched and the matchings written.';

revoke execute on function reconcile_many(uuid[]) from public, anon;
grant execute on function reconcile_many(uuid[]) to authenticated, service_role;

create or replace function reconcile_with_difference(p_line_ids uuid[], p_reason text)
returns table (
  matching_number     text,
  amount              numeric,
  difference          numeric,
  adjustment_entry_id uuid,
  reconciliation_ids  uuid[]
)
language plpgsql
volatile
security invoker
as $$
begin
  if p_reason is null then
    raise exception 'unknown_difference_reason: a difference is booked with its reason; matching_difference_reasons() lists them'
      using errcode = '22023';
  end if;
  return query select * from match_lines(p_line_ids, p_reason);
end;
$$;

comment on function reconcile_with_difference(uuid[], text) is
  'Matches the same set of lines as reconcile_many() when their totals differ by no more than the company''s difference tolerance (matching_difference_tolerance()): posts an entry in the miscellaneous journal, on the day of the latest line, that books the difference on the same account and counterparty against the account the pack gives for p_reason (matching_difference_reasons(): rounding, exchange_difference), then matches everything under one letter. unreconcile() of the matching of the difference line takes the entry back. Refuses as reconcile_many() does, and unknown_difference_reason, no_difference, difference_above_tolerance, no_account_for_reason, account_takes_no_entries, no_miscellaneous_journal.';

revoke execute on function reconcile_with_difference(uuid[], text) from public, anon;
grant execute on function reconcile_with_difference(uuid[], text) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 8. unreconcile — `20261011155443`, and the entry of a difference
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
  end if;

  -- A difference booked by reconcile_with_difference() goes the same way:
  -- every matching of its line, then its mirror, and the line matched with
  -- the mirror's so that neither is left open (decision 0071).
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

    select l.id into v_line
      from entry_lines l join accounts a on a.id = l.account_id
     where l.entry_id = v_adj.id and a.reconcilable;
    select l.id into v_back
      from entry_lines l join accounts a on a.id = l.account_id
     where l.entry_id = v_mirror.id and a.reconcilable;
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
  'Undoes a matching, and with it what the matching had booked: the exchange difference it realised, the difference reconcile_with_difference() booked (every matching of its line goes, its mirror is posted and the two lines are matched together), and the share of a cash-basis tax it had made due. The one way a matching is removed.';

revoke execute on function unreconcile(uuid) from public, anon;
grant execute on function unreconcile(uuid) to authenticated, service_role;
