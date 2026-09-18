-- Ekwo OS — a suggestion looks at the contacts it could be, not at all of them.
--
-- Found by `tests/load/`: `suggest_contacts()` over one month of bank
-- statement — 167 lines, a company of 500 contacts — took 3.5 seconds on
-- PGlite, twenty milliseconds a line, when the five reports beside it answer
-- in tens of milliseconds over the whole ledger. With this migration the same
-- month takes 0.24 seconds, and gives the same answer line for line: the old
-- body and the new were run side by side over the 167 lines and their 974
-- suggestions compared — contact, score, method, sentence and alternatives.
--
-- Nothing is wrong with its plan. `contacts` is reached through its company
-- index and no large table is scanned. The cost is what it does to each row:
-- for every active contact of the company it calls `significant_words()` on
-- the name — a SQL function with an aggregate in it, which Postgres cannot
-- inline and so enters once per contact — and then intersects two arrays up
-- to three times to score the pair. Five hundred contacts is five hundred of
-- those per statement line, and every one of them but a handful ends in
-- `score is null`: the names have no word in common. It was written down as a
-- risk when the function shipped — "O(contacts) per line, fine interactively,
-- heavy for a year of statements" — and this is the measure of it.
--
-- ---------------------------------------------------------------------------
-- What changes
--
-- `contacts.name_words`: the words of the name, stored, worked out by the same
-- `significant_words()` so the two can never split a name differently. It is a
-- generated column, so nothing has to remember to maintain it.
--
-- It holds **every** word, not only the significant ones. How long a word has
-- to be to count is a setting of the company (`matching_settings`), and a
-- stored column cannot depend on a setting; a word of any length is the
-- superset every setting selects from.
--
-- `suggest_contacts()` is replaced whole, with one line added to `by_name`:
-- `c.name_words && v_words`. That is a filter before the scoring and never a
-- change to it, because every score the function gives requires a shared
-- word already:
--
--   - 0.900 and the graded 0.650–0.900 are defined on the intersection of the
--     contact's significant words with the statement's, which is inside the
--     intersection of *all* the contact's words with the statement's;
--   - 0.950 is the two names being equal once trimmed and lowercased. The
--     statement's words are the significant words of that same text, and the
--     function only reaches this point when there is at least one — so the
--     contact's name contains it.
--
-- So no contact that scored before is set aside now, and the scores, the
-- sentences and the count of alternatives are computed by the lines that
-- computed them yesterday. `tests/contact_matching.test.ts` is unchanged and
-- passes; `tests/load/` reports the time.
--
-- ---------------------------------------------------------------------------
-- What is deliberately not here: an index on `name_words`.
--
-- A GIN index on the column is the obvious companion, and it was tried. With
-- 2 500 contacts in the instance, 500 of them in the company, the planner does
-- pick it — and the month of statement goes from 238 ms to 217 ms. The time
-- was never in finding the rows of a company, which `contacts_company_name_idx`
-- already does; it was in the function calls made on each of them. A tenth of
-- the time is not worth an index that every write of a contact has to
-- maintain, so it waits for an instance whose contacts are counted in tens of
-- thousands, and for a plan that asks for it.

alter table contacts
  add column name_words text[] generated always as (significant_words(name, 1)) stored;

comment on column contacts.name_words is
  'Every word of the name, lowercased and deduplicated by significant_words(). Generated. Read by suggest_contacts() to set aside, with one array operator, the contacts whose name shares no word with a statement line — before it scores the ones that do.';

create or replace function suggest_contacts(p_transaction_id uuid)
returns table (
  contact_id   uuid,
  score        numeric,
  method       text,
  because      text,
  alternatives integer
)
language plpgsql
stable
security invoker
as $$
declare
  v_tx     bank_transactions;
  v_policy matching_policy;
  v_words  text[];
begin
  -- Row level security answers this select, so a member of another company
  -- gets nothing and is told nothing.
  select * into v_tx from bank_transactions t where t.id = p_transaction_id;
  if not found then
    raise exception 'not_found: bank transaction %', p_transaction_id
      using errcode = 'no_data_found';
  end if;

  v_policy := matching_policy_of(v_tx.company_id);
  v_words  := significant_words(
                coalesce(v_tx.counterpart_name, v_tx.description),
                v_policy.minimum_word_length);

  return query
  with
  -- 1. The account the money moved from or to. An account identifier is not a
  --    resemblance: either the statement carried the one recorded against the
  --    contact, or it did not. Hence a score of 1, and the only evidence that
  --    needs no threshold.
  by_account as (
    select c.id, 1::numeric as score, 'account'::text as method,
           format('the statement carries the account recorded against %s', c.name) as because
    from contacts c
    where c.company_id = v_tx.company_id
      and v_tx.counterpart_iban is not null
      and c.iban is not null
      and upper(replace(c.iban, ' ', '')) = upper(replace(v_tx.counterpart_iban, ' ', ''))
    union
    select p.contact_id, 1::numeric, 'account',
           format('a motif of %s carries this account', c.name)
    from contact_patterns p
    join contacts c on c.id = p.contact_id
    where p.company_id = v_tx.company_id
      and p.active
      and p.kind = 'counterparty_account'
      and v_tx.counterpart_iban is not null
      and upper(replace(p.value, ' ', '')) = upper(replace(v_tx.counterpart_iban, ' ', ''))
  ),
  -- 2. A motif that was learned or declared. Its score is its confidence: what
  --    it has been worth so far, and nothing else.
  by_pattern as (
    select p.contact_id as id, p.confidence as score,
           ('pattern:' || p.kind::text)::text as method,
           format('%s, a motif of %s confirmed %s of %s times',
                  coalesce(p.value, format('%s to %s', p.amount_min, p.amount_max)),
                  c.name, p.success_count, p.usage_count) as because
    from contact_patterns p
    join contacts c on c.id = p.contact_id
    where p.company_id = v_tx.company_id
      and p.active
      and case p.kind
            when 'name_variation' then
              v_tx.counterpart_name is not null
              and lower(trim(v_tx.counterpart_name)) = lower(trim(p.value))
            when 'description_keyword' then
              v_tx.description is not null
              and position(lower(p.value) in lower(v_tx.description)) > 0
              and not exists (
                select 1 from unnest(coalesce(p.exclude_words, '{}'::text[])) as x(word)
                where position(lower(x.word) in lower(v_tx.description)) > 0
              )
            when 'amount_range' then
              p.currency_code = v_tx.currency_code
              and abs(v_tx.amount) between p.amount_min and p.amount_max
            else false
          end
  ),
  -- 3. The name, compared word by word. Three shapes, from the one that says
  --    the most to the one that says the least, and the last of them is why
  --    `alternatives` exists.
  by_name as (
    select c.id, s.score, 'name'::text as method, s.because
    from contacts c
    cross join lateral (
      select significant_words(c.name, v_policy.minimum_word_length) as words
    ) w
    cross join lateral (
      select
        case
          when lower(trim(c.name)) = lower(trim(coalesce(v_tx.counterpart_name, ''))) then 0.950
          when cardinality(w.words) > 0 and w.words <@ v_words then 0.900
          when cardinality(w.words) > 0 and v_words <@ w.words then 0.900
          when cardinality(array(select unnest(w.words) intersect select unnest(v_words))) > 0 then
            0.650 + 0.250 * (
              cardinality(array(select unnest(w.words) intersect select unnest(v_words)))::numeric
              / least(cardinality(w.words), cardinality(v_words))
            )
          else null
        end as score,
        format('the name on the statement shares %s with %s',
               array_to_string(array(select unnest(w.words) intersect select unnest(v_words)), ', '),
               c.name) as because
    ) s
    where c.company_id = v_tx.company_id
      and c.active
      and cardinality(v_words) > 0
      -- The one line this migration adds. A contact whose name shares no word
      -- with the statement scores nothing below, so it is set aside here, by
      -- an array operator on a stored column, before anything is worked out
      -- about it.
      and c.name_words && v_words
      and s.score is not null
      and s.score >= v_policy.name_threshold
  ),
  all_candidates as (
    select * from by_account
    union all select * from by_pattern
    union all select * from by_name
  )
  select a.id, a.score, a.method, a.because,
         count(*) over (partition by a.method)::integer
  from all_candidates a
  order by a.score desc, a.method;
end;
$$;

comment on function suggest_contacts(uuid) is
  'Who this statement line could be, with the score, the evidence in a sentence, and how many contacts that same evidence reached. It writes nothing and decides nothing: a caller that applies a match on its own is expected to require alternatives = 1. Only the contacts whose name shares a word with the line are scored, through contacts.name_words.';
