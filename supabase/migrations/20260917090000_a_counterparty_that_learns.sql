-- Ekwo OS — who the money came from, and a memory of how we knew.
--
-- A statement line carries a name the bank wrote, an IBAN, a free-text
-- description and an amount. None of them is a contact. Somebody looks at the
-- line, decides it is Acme, and moves on — and the next month the same line
-- arrives and somebody decides the same thing again. That repetition is the
-- work this table removes.
--
-- What is stored is a **motif**: a fact about how this counterparty appears on
-- a statement of this company. Four kinds, and no fifth without a migration:
--
--   counterparty_account the account the money moves from or to
--   name_variation       a form of the name, as the bank writes it
--   description_keyword  a word that appears in the line, with exclusions
--   amount_range         a band of amounts, for a recurring charge
--
-- The first one is **not** called `iban`, deliberately. An IBAN is ISO 13616
-- and about half the world does not use one: the United States identifies an
-- account by an ABA routing number and an account number, Canada by a transit
-- and an institution, Australia by a BSB. The rest of this schema has not
-- learnt that yet — `bank_accounts.iban`, `contacts.iban`,
-- `bank_transactions.counterpart_iban` and `documents.payee_iban` all name the
-- European answer, and the last of them cites BT-84 of EN 16931, which is
-- called *Payment account identifier* and is not an IBAN. That is written up
-- in `docs/international.md` and is somebody's next migration. This table does
-- not add to it: a motif holds the identifier the statement carried, whatever
-- scheme it was written in, and the day the columns above learn to say their
-- scheme, nothing here has to be renamed.
--
-- The vocabulary is closed; only the values are learned. Nothing here is
-- executed, nothing is a regular expression, and nothing chooses a contact on
-- its own: `suggest_contacts()` answers with candidates and the reason for
-- each, and a person — or an agent acting as one — decides.
--
-- The design is not new: it has been running in production in a commercial
-- accounting system since 2025, which is why it carries two incidents of that
-- production as tests rather than as comments. Both are in
-- `tests/contact_matching.test.ts`.

create type contact_pattern_kind as enum (
  'counterparty_account', 'name_variation', 'description_keyword', 'amount_range'
);

comment on type contact_pattern_kind is
  'What a motif remembers. Four values, closed: the account the money moved from or to, a spelling of a name, a word of the description, or a band of amounts. A fifth needs a migration, which is the point — a pack or a user cannot invent a rule here.';

create type contact_pattern_source as enum ('declared', 'learned');

comment on type contact_pattern_source is
  'Where the motif came from: `declared` if somebody wrote it down, `learned` if a confirmation taught it. The two are kept apart because a declared motif is an instruction and a learned one is a statistic.';

-- ---------------------------------------------------------------------------
-- contact_patterns
-- ---------------------------------------------------------------------------

create table contact_patterns (
  id              uuid primary key default gen_random_uuid(),
  company_id      uuid not null references companies(id) on delete cascade,
  contact_id      uuid not null references contacts(id) on delete cascade,
  kind            contact_pattern_kind not null,
  -- The value, for the three motifs that are a piece of text. Null for
  -- `amount_range`, which is the three numeric columns below.
  value           text,
  -- Words that take the motif back. `description_keyword` only: "insurance"
  -- identifies the broker except when the line also says "car", which is the
  -- other broker. A list of words, never an expression.
  exclude_words   text[],
  amount_min      numeric(16, 2),
  amount_max      numeric(16, 2),
  amount_typical  numeric(16, 2),
  currency_code   char(3) references currencies(code),
  -- What the motif has been worth so far. `confidence` is derived from the two
  -- counters by `contact_pattern_confidence()`; it is stored so a query can
  -- order by it without recomputing, and a trigger keeps it honest.
  usage_count     integer not null default 0 check (usage_count >= 0),
  success_count   integer not null default 0 check (success_count >= 0),
  confidence      numeric(4, 3) not null default 0.5
                    check (confidence >= 0 and confidence <= 1),
  last_matched_at timestamptz,
  source          contact_pattern_source not null,
  active          boolean not null default true,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  foreign key (contact_id, company_id) references contacts(id, company_id),
  constraint contact_patterns_success_within_usage
    check (success_count <= usage_count),
  -- Each kind fills its own columns and no others. A motif that is half an
  -- amount range and half a keyword is not a motif, it is a bug that would be
  -- read by whichever branch ran first.
  constraint contact_patterns_shape check (
    case kind
      when 'amount_range' then
        value is null and exclude_words is null
        and amount_min is not null and amount_max is not null
        and currency_code is not null and amount_min <= amount_max
      when 'description_keyword' then
        value is not null
        and amount_min is null and amount_max is null
        and amount_typical is null and currency_code is null
      else
        value is not null and exclude_words is null
        and amount_min is null and amount_max is null
        and amount_typical is null and currency_code is null
    end
  )
);

comment on table contact_patterns is
  'How a counterparty shows up on this company''s statements: one row per learned or declared motif, of four closed kinds. Read by suggest_contacts(), written by confirm_contact(). The core still chooses no contact for anybody — it answers with candidates and says why.';

comment on column contact_patterns.value is
  'The account identifier as the statement wrote it, the spelling of the name, or the keyword. Null exactly when the kind is amount_range. An account identifier is not assumed to be an IBAN: half the world does not have one, and the scheme it is written in is a question the rest of this schema cannot answer yet.';
comment on column contact_patterns.exclude_words is
  'Words that disqualify a line the keyword would otherwise claim. Only a description_keyword carries them.';
comment on column contact_patterns.amount_typical is
  'The amount most often seen inside the band. Never a condition — it orders two candidates that are otherwise equal.';
comment on column contact_patterns.usage_count is
  'How many times this motif has been in front of a decision.';
comment on column contact_patterns.success_count is
  'How many of those decisions confirmed the contact it names.';
comment on column contact_patterns.confidence is
  'success + 1 over usage + 2 — the two counters and nothing else. A motif nobody has used yet is worth 0.5 and says so, instead of claiming certainty from one lucky match.';
comment on column contact_patterns.source is
  'declared by a person, or learned from a confirmation.';
comment on column contact_patterns.active is
  'A motif turned off without being forgotten. An inactive motif is never read; its counters stay, so turning it back on does not restart the learning.';

create unique index contact_patterns_unique_value_idx
  on contact_patterns (company_id, contact_id, kind, value)
  where value is not null;
create unique index contact_patterns_unique_range_idx
  on contact_patterns (company_id, contact_id, kind, amount_min, amount_max, currency_code)
  where value is null;
create index contact_patterns_company_kind_idx
  on contact_patterns (company_id, kind) where active;
create index contact_patterns_contact_idx on contact_patterns (contact_id, company_id);
create index contact_patterns_currency_idx on contact_patterns (currency_code);

create trigger contact_patterns_set_updated_at
  before update on contact_patterns
  for each row execute function set_updated_at();

alter table contact_patterns enable row level security;

create policy contact_patterns_select on contact_patterns
  for select using (has_capability(company_id, 'contacts.read'));
create policy contact_patterns_write on contact_patterns
  for all using (has_capability(company_id, 'contacts.write'))
  with check (has_capability(company_id, 'contacts.write'));

comment on policy contact_patterns_select on contact_patterns is
  'Whoever may read a contact may read what is known about how it appears on a statement.';
comment on policy contact_patterns_write on contact_patterns is
  'contacts.write: a motif is knowledge about a contact, and changing it changes who future money is attributed to.';

grant select, insert, update, delete on table contact_patterns
  to authenticated, service_role;

create trigger contact_patterns_audit
  after insert or update or delete on contact_patterns
  for each row execute function audit_changes('{"company":"company_id","key":["kind","value"]}');

-- ---------------------------------------------------------------------------
-- The numbers the matching runs on
--
-- The system this comes from holds them as literals inside a function: 0.60 to
-- accept a name, one cent of tolerance on an amount, two on a sum, ninety days
-- of window. They are good numbers — they come from two years of use — and a
-- literal is still the wrong place for them, because the moment a company
-- disagrees the only way to say so is a fork.
--
-- They are also not all the same kind of number. A tolerance in *cents* is a
-- statement about the euro; a quarter of the world's currencies has no cents
-- and three currencies have three decimals. So a tolerance here is counted in
-- **units of the currency's own smallest denomination**, resolved through
-- `rounding_of()`, and never in hundredths of anything.
-- ---------------------------------------------------------------------------

create table matching_settings (
  company_id                uuid primary key references companies(id) on delete cascade,
  name_threshold            numeric(4, 3) check (name_threshold >= 0 and name_threshold <= 1),
  amount_tolerance_units    integer check (amount_tolerance_units >= 0),
  sum_tolerance_units       integer check (sum_tolerance_units >= 0),
  date_window_days          integer check (date_window_days >= 0),
  minimum_word_length       integer check (minimum_word_length >= 1),
  created_at                timestamptz not null default now(),
  updated_at                timestamptz not null default now()
);

comment on table matching_settings is
  'What this company considers close enough. Every column is nullable and null means the shipped answer, which lives in matching_policy_of() and nowhere else — so a reader always gets a number and a company that never had an opinion has no row.';
comment on column matching_settings.name_threshold is
  'How much of a name has to agree before a contact is proposed at all, between 0 and 1.';
comment on column matching_settings.amount_tolerance_units is
  'How many smallest units of the currency two amounts may differ by and still be the same payment. Units, not cents: the currency says how much a unit is worth.';
comment on column matching_settings.sum_tolerance_units is
  'The same, for a transaction that pays several documents at once, where each of them was rounded on its own.';
comment on column matching_settings.date_window_days is
  'How far from a document a payment may sit and still be proposed for it.';
comment on column matching_settings.minimum_word_length is
  'How long a word has to be to count as evidence of a name.';

create trigger matching_settings_set_updated_at
  before update on matching_settings
  for each row execute function set_updated_at();

alter table matching_settings enable row level security;

create policy matching_settings_select on matching_settings
  for select using (is_company_member(company_id));
create policy matching_settings_write on matching_settings
  for all using (has_capability(company_id, 'company.write'))
  with check (has_capability(company_id, 'company.write'));

comment on policy matching_settings_select on matching_settings is
  'A member reads how their company matches, the way they read the company itself.';
comment on policy matching_settings_write on matching_settings is
  'company.write: these numbers decide what gets attributed automatically, which is a decision about the company and not about one contact.';

grant select, insert, update, delete on table matching_settings
  to authenticated, service_role;

create trigger matching_settings_audit
  after insert or update or delete on matching_settings
  for each row execute function audit_changes('{"company":"company_id"}');

create type matching_policy as (
  name_threshold         numeric,
  amount_tolerance_units integer,
  sum_tolerance_units    integer,
  date_window_days       integer,
  minimum_word_length    integer
);

comment on type matching_policy is
  'The five numbers the matching runs on, resolved for one company.';

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
  select row(
    coalesce(s.name_threshold,         0.600),
    coalesce(s.amount_tolerance_units, 1),
    coalesce(s.sum_tolerance_units,    2),
    coalesce(s.date_window_days,       90),
    coalesce(s.minimum_word_length,    4)
  )::matching_policy
  from (select p_company_id as company_id) c
  left join matching_settings s on s.company_id = c.company_id;
$$;

comment on function matching_policy_of(uuid) is
  'The five numbers, for this company: its own where it has an opinion, the shipped ones otherwise. The only function that carries a default.';

revoke execute on function matching_policy_of(uuid) from public, anon;
grant execute on function matching_policy_of(uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- The words of a name
--
-- Two names agree when they share a word long enough to mean something. What
-- is deliberately **not** here is a list of legal forms to ignore — `sarl`,
-- `bvba`, `gmbh`, `llc`. Such a list is country data, it would be a literal in
-- the core, and this repository refuses those on principle.
--
-- It is not needed either, because a better rule falls out of the data: a word
-- that reaches several contacts of the company identifies none of them.
-- Thirty suppliers called "… SARL" make `sarl` worthless without anybody
-- having to say so, and the same rule catches the word this list would have
-- forgotten — a town, a trade, the name of a group. `suggest_contacts()`
-- therefore counts how many contacts each piece of evidence reaches and says
-- so, and a caller applying a match on its own is expected to refuse anything
-- that reached more than one.
--
-- This was learned the hard way on 16 April 2026: matching on the first five
-- characters of a name made `SARL` equal to `SASU` and `SPRL`, and unrelated
-- suppliers were matched to each other. `tests/contact_matching.test.ts` keeps
-- that incident as a test.
-- ---------------------------------------------------------------------------

create or replace function significant_words(p_text text, p_minimum_length integer)
returns text[]
language sql
immutable
as $$
  select coalesce(array_agg(distinct w), '{}'::text[])
  from regexp_split_to_table(
         lower(translate(coalesce(p_text, ''), '.,&()/-_''"+*:;#', '                ')),
         '\s+'
       ) as w
  where length(w) >= p_minimum_length;
$$;

comment on function significant_words(text, integer) is
  'The words of a name that are long enough to be evidence, lowercased and deduplicated. No stop list: a word shared by several contacts is disqualified by the count of what it reaches, which is a fact about this company rather than an opinion about a language.';

revoke execute on function significant_words(text, integer) from public, anon;
grant execute on function significant_words(text, integer) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- suggest_contacts
--
-- Read-only, and it decides nothing. It answers with every contact the line
-- could be, the score of each, the evidence, and — the column that matters —
-- how many contacts that same evidence reached. One is a recognition; two is
-- a coincidence with a name on it.
-- ---------------------------------------------------------------------------

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
  'Who this statement line could be, with the score, the evidence in a sentence, and how many contacts that same evidence reached. It writes nothing and decides nothing: a caller that applies a match on its own is expected to require alternatives = 1.';

revoke execute on function suggest_contacts(uuid) from public, anon;
grant execute on function suggest_contacts(uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- confirm_contact
--
-- The only place a motif is learned, because the only thing worth learning
-- from is a decision somebody stands behind.
--
-- It also does the unglamorous half: a motif that pointed at somebody else is
-- charged a use and not a success, so being wrong costs confidence. Without
-- that, every motif converges on certainty and the oldest mistake wins.
-- ---------------------------------------------------------------------------

create or replace function confirm_contact(p_transaction_id uuid, p_contact_id uuid)
returns bank_transactions
language plpgsql
volatile
security invoker
as $$
declare
  v_tx      bank_transactions;
  v_contact contacts;
  v_policy  matching_policy;
begin
  select * into v_tx from bank_transactions t where t.id = p_transaction_id;
  if not found then
    raise exception 'not_found: bank transaction %', p_transaction_id
      using errcode = 'no_data_found';
  end if;

  select * into v_contact
  from contacts c
  where c.id = p_contact_id and c.company_id = v_tx.company_id;
  if not found then
    raise exception 'contact_not_of_company: % is not a contact of the company this line belongs to',
      p_contact_id;
  end if;

  v_policy := matching_policy_of(v_tx.company_id);

  -- Every motif that named somebody else has now been in front of a decision
  -- and lost it. Charged first, so that a motif that also named the right
  -- contact is not punished for it below.
  update contact_patterns p
     set usage_count = p.usage_count + 1,
         confidence  = (p.success_count + 1)::numeric / (p.usage_count + 3)
   where p.id in (
     select cp.id
     from contact_patterns cp
     join suggest_contacts(p_transaction_id) s
       on s.contact_id = cp.contact_id
      and s.method = 'pattern:' || cp.kind::text
     where cp.company_id = v_tx.company_id
       and cp.contact_id <> p_contact_id
   );

  -- The account, when the statement carried one. This is the motif worth the
  -- most, and the one a bank writes identically every time.
  if v_tx.counterpart_iban is not null then
    insert into contact_patterns (company_id, contact_id, kind, value, source,
                                  usage_count, success_count, confidence, last_matched_at)
    values (v_tx.company_id, p_contact_id, 'counterparty_account',
            upper(replace(v_tx.counterpart_iban, ' ', '')), 'learned',
            1, 1, 2::numeric / 3, now())
    on conflict (company_id, contact_id, kind, value) where value is not null
    do update set usage_count     = contact_patterns.usage_count + 1,
                  success_count   = contact_patterns.success_count + 1,
                  confidence      = (contact_patterns.success_count + 2)::numeric
                                    / (contact_patterns.usage_count + 3),
                  last_matched_at = now(),
                  active          = true;
  end if;

  -- The name as this bank writes it, which is rarely the name in the ledger.
  -- Stored only when it carries a word worth comparing: a line whose name is
  -- "PAIEMENT" teaches nothing.
  if v_tx.counterpart_name is not null
     and cardinality(significant_words(v_tx.counterpart_name, v_policy.minimum_word_length)) > 0
  then
    insert into contact_patterns (company_id, contact_id, kind, value, source,
                                  usage_count, success_count, confidence, last_matched_at)
    values (v_tx.company_id, p_contact_id, 'name_variation',
            trim(v_tx.counterpart_name), 'learned', 1, 1, 2::numeric / 3, now())
    on conflict (company_id, contact_id, kind, value) where value is not null
    do update set usage_count     = contact_patterns.usage_count + 1,
                  success_count   = contact_patterns.success_count + 1,
                  confidence      = (contact_patterns.success_count + 2)::numeric
                                    / (contact_patterns.usage_count + 3),
                  last_matched_at = now(),
                  active          = true;
  end if;

  update bank_transactions t
     set contact_id = p_contact_id
   where t.id = p_transaction_id
  returning * into v_tx;

  return v_tx;
end;
$$;

comment on function confirm_contact(uuid, uuid) is
  'Attributes a statement line to a contact and learns from it: the account and the name as this bank writes them become motifs, and every motif that had named somebody else is charged a use without a success. Knowing who the money came from is not knowing what it pays — this function never touches a document and never reconciles anything.';

revoke execute on function confirm_contact(uuid, uuid) from public, anon;
grant execute on function confirm_contact(uuid, uuid) to authenticated, service_role;
