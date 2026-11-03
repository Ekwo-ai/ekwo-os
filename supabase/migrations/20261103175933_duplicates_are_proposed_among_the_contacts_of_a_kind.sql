-- Ekwo OS — duplicates are proposed among the contacts of a kind (decision
-- 0075, amended).
--
-- `suggest_duplicate_contacts()` (`20261027190000`) read every contact of a
-- company. A company whose contacts are mostly kept beside the books — the
-- people and organisations a relation-client module imports, as type
-- `other` — has them all walked to propose duplicates among a few hundred
-- customers and suppliers: on a company of 33 082 contacts, 228 of them
-- parties of the books, the reading took 10.7 s, past the 8 s
-- `statement_timeout` of `authenticated` on Supabase, and the books' page
-- showed the cancellation instead of the proposals.
--
-- **A reader names the types it proposes among.** A second argument,
-- `p_contact_types`, keeps in the pool only the contacts of those types: the
-- books' page asks for `customer`, `supplier` and `both`, the screen of the
-- relation-client module will ask for the rest. Left null — its default —
-- every contact is read, as before, so a call naming the company alone
-- answers exactly what it answered: the MCP tool, the command line and the
-- Cloud of the previous release keep working unchanged, and PostgREST
-- resolves a call with `p_company_id` alone as well as one with both.
--
-- What a word of a name weighs is counted over the same pool: asked for
-- the parties of the books, a word is rare or common among them, not among
-- the thousands of contacts kept beside them.
--
-- The function is dropped and created again because an argument is added;
-- its columns, their meaning and their order are unchanged.

drop function if exists ekwo.suggest_duplicate_contacts(uuid);

create or replace function ekwo.suggest_duplicate_contacts(
  p_company_id uuid,
  p_contact_types ekwo.contact_type[] default null
)
returns table (
  keep_id   uuid,
  absorb_id uuid,
  score     numeric,
  evidence  text,
  because   text,
  proposed_name text
)
language plpgsql
stable
security invoker
-- Every join below is on a value — a word, a number, an account, an id — and
-- the pool is the company's contacts of the types asked, thousands at most:
-- a hash join is right whatever the statistics of the moment say. Left to an
-- estimate of a handful of rows, the planner nests loops over two thousand
-- contacts and takes seconds.
set enable_nestloop = off
as $$
#variable_conflict use_column
declare
  v_policy matching_policy;
begin
  v_policy := matching_policy_of(p_company_id);

  return query
  with recursive
  -- The contacts that may still be merged: active, merged into nobody, of
  -- the types asked for, of any type when none is. Two sets of words: every
  -- word of the name (`tokens`), and those long enough to count (`words`).
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
      and (p_contact_types is null or c.contact_type = any (p_contact_types))
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
  -- 3. The group. The contacts the pairs join, directly or through a third,
  --    walked from each contact along the pairs; a contact's group is named
  --    by the smallest id it reaches (uuid has no min: compared as text). `union`, not `union all`: a contact
  --    reached again is not walked again, so a ring of pairs ends.
  edges as (
    select x.lo as id, x.hi as other from pairs x
    union all
    select x.hi, x.lo from pairs x
  ),
  walk(id, reached) as (
    select e.id, e.id from edges e
    union
    select w.id, e.other
    from walk w
    join edges e on e.id = w.reached
  ),
  grouped as (
    select w.id, min(w.reached::text)::uuid as root
    from walk w
    group by w.id
  ),
  -- What the books name each contact of a group by: its ledger lines and its
  -- documents.
  activity as (
    select p.id, p.created_at,
           (select count(*) from entry_lines l where l.contact_id = p.id and l.company_id = p_company_id)
         + (select count(*) from documents d where d.contact_id = p.id and d.company_id = p_company_id) as uses
    from pool p
    where p.id in (select g.id from grouped g)
  ),
  kept as (
    select distinct on (g.root) g.root, g.id as keep_id
    from grouped g
    join activity a on a.id = g.id
    order by g.root, a.uses desc, a.created_at, g.id
  ),
  -- 4. The name proposed for the group: each word of each name, with how many
  --    contacts outside the group carry it.
  carried as (
    select g.root, g.id, u.word,
           r.contacts - count(*) over (partition by g.root, u.word) as outside
    from grouped g
    join pool p on p.id = g.id
    cross join lateral unnest(p.tokens) as u(word)
    join reach r on r.word = u.word
  ),
  simplest as (
    select distinct on (c.root) c.root, p.name
    from (
      select c.root, c.id,
             count(*) filter (where c.outside > 0) as common,
             count(*) as words
      from carried c
      group by c.root, c.id
    ) c
    join pool p on p.id = c.id
    join kept k on k.root = c.root
    order by c.root, c.common, c.words, length(p.name), (c.id = k.keep_id) desc, p.name
  ),
  -- 5. One row per contact absorbed, with its strongest pair — the pair with
  --    the kept contact first — and the name proposed for the group.
  sides as (
    select x.lo as id, x.hi as other, x.score, x.evidence, x.because, x.kinds from pairs x
    union all
    select x.hi, x.lo, x.score, x.evidence, x.because, x.kinds from pairs x
  ),
  told as (
    select distinct on (g.id) k.keep_id, g.id as absorb_id, g.root, s.score, s.evidence, s.because, s.kinds
    from grouped g
    join kept k on k.root = g.root
    join sides s on s.id = g.id
    where g.id <> k.keep_id
    order by g.id, (s.other = k.keep_id) desc, s.score desc, s.kinds desc, s.because
  )
  select t.keep_id, t.absorb_id, t.score, t.evidence, t.because,
         coalesce(s.name, pk.name)
  from told t
  join pool pa on pa.id = t.absorb_id
  join pool pk on pk.id = t.keep_id
  left join simplest s on s.root = t.root
  -- What merge_contacts() would refuse of a contact and the kept one, joined
  -- through a third.
  where not (pa.vat is not null and pk.vat is not null and pa.vat <> pk.vat)
    and not (pa.registration is not null and pk.registration is not null and pa.registration <> pk.registration)
    and pa.parent_id is distinct from pk.id
    and pk.parent_id is distinct from pa.id
  order by t.score desc, t.kinds desc, t.because;
end;
$$;

comment on function ekwo.suggest_duplicate_contacts(uuid, ekwo.contact_type[]) is
  'The contacts of a company that are probably one party (decision 0075): one row per contact to absorb, strongest first — keep_id, the contact of its group the most ledger lines and documents name (then the older), absorb_id, score from 0 to 1, evidence (the kinds, strongest first, comma-separated: vat_number, registration_number, account, name), because (the evidence in sentences) and proposed_name, the simplest name the group carries (the fewest words carried by contacts outside the group, then the fewest words, then the shortest). The pairs are found on the same VAT or registration number (party_identifier()), the same bank account on the contact or in a learned motif (account_key()), both scoring 1, and by name, each word weighing 1 over the contacts of the company that carry it, scored as contact_candidates() scores a name; the contacts a chain of pairs joins are one group, with one contact to keep. Rows of one group share their keep_id. A pair across companies, with two different VAT or registration numbers, or of a contact and its own parent is never proposed. It writes nothing and decides nothing; merge_contacts() joins a pair a person chose, and the name proposed is written only by the person. p_contact_types keeps the contacts of those types only, every contact when null: the page of the books asks for the parties of the books (customer, supplier, both), the relation-client screen for the rest.';

revoke execute on function ekwo.suggest_duplicate_contacts(uuid, ekwo.contact_type[]) from public, anon;
grant execute on function ekwo.suggest_duplicate_contacts(uuid, ekwo.contact_type[]) to authenticated, service_role;
