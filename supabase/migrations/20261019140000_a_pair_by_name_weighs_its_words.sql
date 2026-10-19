-- Ekwo OS — a pair of contacts by name weighs its words (decision 0075,
-- amended).
--
-- `suggest_duplicate_contacts()` (`20261019104812`) proposed a pair when every
-- significant word of one name was in the other. On books of about two hundred
-- contacts that made pairs of "LG SERVICES" and "ASBL UCM SERVICES", "P & V
-- Verzekeringen" and "KBC Verzekeringen", "Parking" and "Parking Cathédrale
-- SA", "DKV Belgium" and "APPLE RETAIL BELGIUM BV": one word in common, a
-- trade, a place, a legal form, and nothing else. The first rule only looked
-- at the words long enough to count, so the mark that tells two parties apart
-- — "LG", "KBC", "DKV", "CE" — was below the minimum length and never read;
-- and it never asked what the longer name said beyond the shorter.
--
-- **Each word weighs by how rare it is among the company's contacts.** A word
-- carried by one contact weighs 1, by two 1/2, by ten 1/10: a word many
-- contacts carry says little about which party a name is. Every word of the
-- name counts, at any length (`contacts.name_words`), so a legal form carried
-- by thirty contacts weighs 1/30 and the initials of one party weigh 1. No
-- list of legal forms: the core has none, it would be country data, and the
-- count is a fact about this company that catches the trade and the town as
-- well (`significant_words()`, `20260917090000`).
--
-- **A pair by name is two names whose words agree, weighed.** For the shorter
-- name `a` and the longer `b`:
--
--   * the rarest significant word of `a` — at the company's minimum length —
--     is in `b`: the pair holds on a word that names somebody;
--   * what only one of them says weighs no more than what they share. What
--     they share is the significant words of `a` that are in `b`. What only
--     one says is every word of `a` missing from `b`, at any length — a
--     shorter writing of a name drops words, it does not invent them — and the
--     significant words of `b` missing from `a`. The words of `b` below the
--     minimum length are not counted against the pair: a name written in full
--     grows by its legal form ("Anthropic, PBC", "Supabase Pte Ltd", "ISABEL
--     NV"), and those are the words the minimum length exists for.
--
-- So, where each of these words is carried by one contact or by the two of
-- the pair: "LG SERVICES" is not "ASBL UCM SERVICES" (`lg` and `asbl` weigh
-- 2, `services` 1/2), "Parking" is not "Parking Cathédrale SA" (`cathédrale`
-- weighs 1, `parking` 1/2), and "Garage Annez" is "Garage Annez et fils" (they
-- share 1; `fils` weighs 1, and `et` is a word of the longer below the minimum
-- length). The same name, in any case, is still a pair whatever its words.
--
-- The score is unchanged: `name_agreement()` and `name_among_several()`, as
-- `contact_candidates()` scores a name, capped at 0.600 when the shorter name
-- agrees with several contacts. `contact_candidates()` is not touched, and
-- neither is any suggestion for a statement or a ledger line. The identifiers
-- — VAT number, registration number, bank account — are not touched either.
--
-- Still bounded: the candidates of each name are the holders of its rarest
-- significant word, as before; the weighing reads the words of the pairs
-- found, joined once on the count of each word.

create or replace function suggest_duplicate_contacts(p_company_id uuid)
returns table (
  keep_id   uuid,
  absorb_id uuid,
  score     numeric,
  evidence  text,
  because   text
)
language plpgsql
stable
security invoker
-- Every join below is on a value — a word, a number, an account, an id — and
-- the pool is the company's contacts, thousands at most: a hash join is right
-- whatever the statistics of the moment say. Left to an estimate of a handful
-- of rows, the planner nests loops over two thousand contacts and takes
-- seconds.
set enable_nestloop = off
as $$
#variable_conflict use_column
declare
  v_policy matching_policy;
begin
  v_policy := matching_policy_of(p_company_id);

  return query
  with
  -- The contacts that may still be merged: active, merged into nobody. Two
  -- sets of words: every word of the name (`tokens`), and those long enough
  -- to count (`words`).
  pool as materialized (
    select c.id, c.name, c.created_at, c.parent_id,
           c.name_words as tokens,
           significant_words(c.name, v_policy.minimum_word_length) as words,
           party_identifier(c.vat_number) as vat,
           party_identifier(c.registration_number) as registration,
           account_key(c.iban) as iban
    from contacts c
    where c.company_id = p_company_id
      and c.active
      and c.merged_into is null
  ),
  -- 1. An identifier both carry: a number, a bank account on the contact or
  --    in a learned motif. Joined on its value, never contact by contact.
  keys as (
    select p.id, 'vat_number'::text as kind, p.vat as value, 'the VAT number'::text as what
    from pool p where p.vat is not null
    union
    select p.id, 'registration_number', p.registration, 'the registration number'
    from pool p where p.registration is not null
    union
    select p.id, 'account', p.iban, 'the bank account'
    from pool p where p.iban is not null
    union
    select p.id, 'account', account_key(m.value), 'the bank account'
    from contact_patterns m
    join pool p on p.id = m.contact_id
    where m.company_id = p_company_id
      and m.active
      and m.kind = 'counterparty_account'
      and account_key(m.value) is not null
  ),
  by_key as (
    select a.id as lo, b.id as hi, a.kind, 1.000::numeric as score,
           format('%s and %s carry %s %s', pa.name, pb.name, a.what, a.value) as because
    from keys a
    join keys b on b.kind = a.kind and b.value = a.value and b.id > a.id
    join pool pa on pa.id = a.id
    join pool pb on pb.id = b.id
  ),
  -- 2. The name. How many contacts carry each word, at any length: what a
  --    word weighs.
  reach as (
    select u.word, count(*) as contacts
    from pool p cross join lateral unnest(p.tokens) as u(word)
    group by u.word
  ),
  holders as (
    select p.id, u.word
    from pool p cross join lateral unnest(p.words) as u(word)
  ),
  rarest as (
    select distinct on (h.id) h.id, h.word
    from holders h join reach r on r.word = h.word
    order by h.id, r.contacts, h.word
  ),
  -- Directed: `a` is the name read as the shorter, and its rarest
  -- significant word is in the name of `b`.
  name_pairs as (
    select r.id as a_id, h.id as b_id
    from rarest r
    join holders h on h.word = r.word and h.id <> r.id
    union
    -- The same name with no word long enough to count still names one party.
    select a.id, b.id
    from pool a
    join pool b on lower(trim(b.name)) = lower(trim(a.name)) and b.id <> a.id
  ),
  -- What the two share — the significant words of `a` in `b` — and what only
  -- one of them says — every word of `a` missing from `b`, the significant
  -- words of `b` missing from `a` — each word at 1 over the contacts that
  -- carry it.
  weighed as (
    select n.a_id, n.b_id,
           coalesce(sum(1::numeric / r.contacts)
                      filter (where s.side = 'a' and s.shared
                                and length(s.word) >= v_policy.minimum_word_length), 0) as shared,
           coalesce(sum(1::numeric / r.contacts) filter (where not s.shared), 0) as apart
    from name_pairs n
    join pool a on a.id = n.a_id
    join pool b on b.id = n.b_id
    cross join lateral (
      select 'a'::text as side, u.word, u.word = any (b.tokens) as shared
      from unnest(a.tokens) as u(word)
      union all
      select 'b', u.word, u.word = any (a.tokens)
      from unnest(b.words) as u(word)
    ) s
    join reach r on r.word = s.word
    group by n.a_id, n.b_id
  ),
  agreeing as (
    select n.a_id, n.b_id
    from name_pairs n
    join pool a on a.id = n.a_id
    join pool b on b.id = n.b_id
    left join weighed w on w.a_id = n.a_id and w.b_id = n.b_id
    where lower(trim(a.name)) = lower(trim(b.name))
       or (w.shared > 0 and w.apart <= w.shared)
  ),
  named as (
    select n.a_id, n.b_id, a.name as a_name, b.name as b_name, a.words, b.words as b_words,
           name_agreement(a.name, a.words, b.name, b.words) as agreement,
           -- How many contacts the name of `a` agrees with, as
           -- contact_candidates() counts what a text reaches.
           count(*) over (partition by n.a_id) as reached
    from agreeing n
    join pool a on a.id = n.a_id
    join pool b on b.id = n.b_id
  ),
  -- One sentence a pair, from the direction that says it best: the higher
  -- score, then the name whose words are all in the other, then the shorter.
  by_name as (
    select distinct on (least(n.a_id, n.b_id), greatest(n.a_id, n.b_id))
           least(n.a_id, n.b_id) as lo, greatest(n.a_id, n.b_id) as hi, 'name'::text as kind,
           name_among_several(n.agreement, n.reached) as score,
           case
             when n.agreement >= 0.950 then format('%s and %s carry the same name', n.a_name, n.b_name)
             when n.words @> n.b_words and n.words <@ n.b_words
               then format('%s and %s carry the same words: %s', n.a_name, n.b_name,
                           array_to_string(array(select unnest(n.words) order by 1), ', '))
             when n.words <@ n.b_words then format('every word of %s is in %s', n.a_name, n.b_name)
             else format('%s and %s share %s, and what only one of them carries is common', n.a_name, n.b_name,
                         array_to_string(array(select unnest(n.words) intersect select unnest(n.b_words) order by 1), ', '))
           end
           || case when n.reached > 1 and n.agreement < 0.950
                   then format('; the words of %s are in the names of %s contacts', n.a_name, n.reached)
                   else '' end as because
    from named n
    where n.agreement is not null
      and name_among_several(n.agreement, n.reached) >= v_policy.name_threshold
    order by least(n.a_id, n.b_id), greatest(n.a_id, n.b_id),
             name_among_several(n.agreement, n.reached) desc,
             (n.words <@ n.b_words) desc, cardinality(n.words), n.a_name
  ),
  -- The strongest sentence of each kind of evidence, for each pair.
  facts as (
    select distinct on (e.lo, e.hi, e.kind) e.lo, e.hi, e.kind, e.score, e.because,
           array_position(array['vat_number', 'registration_number', 'account', 'name'], e.kind) as rank
    from (select * from by_key union all select * from by_name) e
    order by e.lo, e.hi, e.kind, e.score desc, e.because
  ),
  pairs as (
    select e.lo, e.hi, max(e.score) as score,
           string_agg(e.kind, ',' order by e.score desc, e.rank) as evidence,
           string_agg(e.because, '; ' order by e.score desc, e.rank) as because,
           count(*) as kinds
    from facts e
    join pool a on a.id = e.lo
    join pool b on b.id = e.hi
    -- What merge_contacts() would refuse, and a contact with its own branch.
    where not (a.vat is not null and b.vat is not null and a.vat <> b.vat)
      and not (a.registration is not null and b.registration is not null and a.registration <> b.registration)
      and a.parent_id is distinct from b.id
      and b.parent_id is distinct from a.id
    group by e.lo, e.hi
  ),
  -- What the books name each contact of a pair by: its ledger lines and its
  -- documents.
  activity as (
    select p.id, p.created_at,
           (select count(*) from entry_lines l where l.contact_id = p.id and l.company_id = p_company_id)
         + (select count(*) from documents d where d.contact_id = p.id and d.company_id = p_company_id) as uses
    from pool p
    where p.id in (select x.lo from pairs x union select x.hi from pairs x)
  ),
  ordered as (
    select x.*,
           (a.uses > b.uses
            or (a.uses = b.uses and (a.created_at < b.created_at
                                     or (a.created_at = b.created_at and a.id < b.id)))) as lo_kept
    from pairs x
    join activity a on a.id = x.lo
    join activity b on b.id = x.hi
  )
  select case when o.lo_kept then o.lo else o.hi end,
         case when o.lo_kept then o.hi else o.lo end,
         o.score, o.evidence, o.because
  from ordered o
  order by o.score desc, o.kinds desc, o.because;
end;
$$;

comment on function suggest_duplicate_contacts(uuid) is
  'The contacts of a company that are probably one party (decision 0075): one row per pair of active contacts merged into nobody, strongest first — keep_id, the one more ledger lines and documents name (then the older), absorb_id, score from 0 to 1, evidence (the kinds, strongest first, comma-separated: vat_number, registration_number, account, name) and because (the evidence in sentences). The same VAT or registration number (party_identifier()) and the same bank account on the contact or in a learned motif (account_key()) score 1. By name, each word weighs 1 over the contacts of the company that carry it: a pair needs the rarest significant word of the shorter name in the longer, and what only one name says — every word of the shorter missing from the longer, the significant words of the longer missing from the shorter — weighing no more than the significant words they share; the same name is always a pair. It scores as contact_candidates() scores a name (name_agreement(), capped by name_among_several() when the shorter name agrees with several contacts), from the company''s matching policy. A pair across companies, with two different VAT or registration numbers, or of a contact and its own parent is never proposed. It writes nothing and decides nothing; merge_contacts() joins a pair a person chose.';

revoke execute on function suggest_duplicate_contacts(uuid) from public, anon;
grant execute on function suggest_duplicate_contacts(uuid) to authenticated, service_role;
