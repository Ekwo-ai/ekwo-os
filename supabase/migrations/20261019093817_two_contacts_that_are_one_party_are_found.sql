-- Ekwo OS — two contacts that are probably one party are found (decision 0075).
--
-- `merge_contacts()` (decision 0074) joins two contacts once a person has
-- seen that they are one party. Seeing it was left to the person: books taken
-- over in two passes create "Marlow Jane" and "Jane Marlow", and nothing
-- pointed at the pair. `suggest_contact_duplicates(company)` does, with the
-- evidence of each pair, and decides nothing.
--
-- **The evidence is the evidence the books already use to recognise a
-- party** (decision 0045, `contact_candidates()`), on its own scale:
--
--   - an identifier both carry — the same VAT number, the same registration
--     number, the same bank account — scores 1: either the two carry it or
--     they do not, as an account is in `contact_candidates()`;
--   - the same name, letter for letter, scores 0.950, as a label that is a
--     contact's whole name does;
--   - the words of one name all inside the other's — the same words in
--     another order, or a name and its longer form — score 0.900, as the
--     words of a contact's name inside a label do.
--
-- A name that only shares some of its words with another is not proposed: a
-- word two parties share is a coincidence until the rest agrees. The words
-- are the company's significant words (`matching_settings`, through
-- `matching_policy_of()`), so a legal form shorter than the company's minimum
-- does not make two companies one.
--
-- **A pair `merge_contacts()` would refuse is not proposed.** Two different
-- VAT numbers, or two different registration numbers, are two legal persons
-- whatever their names say (`different_identifiers`); a merged contact is
-- already retired into another (`already_merged`), and an inactive one is
-- not in use. What is left can be merged as it is proposed.
--
-- **Which one to keep is proposed, not decided.** The contact more rows name
-- — ledger lines and documents — is proposed as the one to keep, since it
-- moves less; on a tie, the older one. The person may keep the other:
-- `merge_contacts()` takes the two in either order.
--
-- One row per pair, with its strongest evidence in a sentence and every kind
-- of evidence found in `evidence`. It is `security invoker`: a person sees
-- the pairs of the contacts they can read, counted with the lines and
-- documents they can read.

create or replace function suggest_contact_duplicates(p_company_id uuid)
returns table (
  keep_id      uuid,
  keep_name    text,
  absorb_id    uuid,
  absorb_name  text,
  score        numeric,
  method       text,
  because      text,
  evidence     text[],
  keep_rows    integer,
  absorb_rows  integer
)
language plpgsql
stable
security invoker
set search_path = public, pg_temp
as $$
declare
  v_policy matching_policy;
begin
  v_policy := matching_policy_of(p_company_id);

  return query
  with
  candidates as (
    select c.id, c.name, c.created_at,
           nullif(upper(regexp_replace(coalesce(c.vat_number, ''), '[^0-9A-Za-z]', '', 'g')), '') as vat,
           nullif(upper(regexp_replace(coalesce(c.registration_number, ''), '[^0-9A-Za-z]', '', 'g')), '') as registration,
           nullif(upper(replace(coalesce(c.iban, ''), ' ', '')), '') as account,
           significant_words(c.name, v_policy.minimum_word_length) as words
    from contacts c
    where c.company_id = p_company_id
      and c.active
      and c.merged_into is null
  ),
  -- Each pair once, the smaller id first; two numbers are two parties.
  pairs as (
    select a.id as a_id, a.name as a_name, b.id as b_id, b.name as b_name,
           a.vat as a_vat, b.vat as b_vat, a.registration as a_registration, b.registration as b_registration,
           a.account as a_account, b.account as b_account, a.words as a_words, b.words as b_words
    from candidates a
    join candidates b on b.id > a.id
    where not (a.vat is not null and b.vat is not null and a.vat <> b.vat)
      and not (a.registration is not null and b.registration is not null and a.registration <> b.registration)
      and (
        a.vat = b.vat
        or a.registration = b.registration
        or a.account = b.account
        or (cardinality(a.words) > 0 and cardinality(b.words) > 0
            and (a.words <@ b.words or b.words <@ a.words))
        or lower(btrim(a.name)) = lower(btrim(b.name))
      )
  ),
  facts as (
    select p.a_id, p.b_id, f.score, f.method, f.because
    from pairs p
    cross join lateral (
      values
        (case when p.a_vat = p.b_vat then 1.000 end, 'vat_number',
         format('%s and %s carry the VAT number %s', p.a_name, p.b_name, p.a_vat)),
        (case when p.a_registration = p.b_registration then 1.000 end, 'registration_number',
         format('%s and %s carry the registration number %s', p.a_name, p.b_name, p.a_registration)),
        (case when p.a_account = p.b_account then 1.000 end, 'account',
         format('%s and %s carry the account %s', p.a_name, p.b_name, p.a_account)),
        (case
           when lower(btrim(p.a_name)) = lower(btrim(p.b_name)) then 0.950
           when cardinality(p.a_words) > 0 and cardinality(p.b_words) > 0
                and (p.a_words <@ p.b_words or p.b_words <@ p.a_words) then 0.900
         end,
         'name',
         case
           when lower(btrim(p.a_name)) = lower(btrim(p.b_name))
             then format('%s and %s carry the same name', p.a_name, p.b_name)
           when p.a_words <@ p.b_words and p.b_words <@ p.a_words
             then format('%s and %s are the same words in another order', p.a_name, p.b_name)
           when p.a_words <@ p.b_words
             then format('every word of %s is in %s', p.a_name, p.b_name)
           else format('every word of %s is in %s', p.b_name, p.a_name)
         end)
    ) as f(score, method, because)
    where f.score is not null
  ),
  best as (
    select distinct on (f.a_id, f.b_id) f.a_id, f.b_id, f.score, f.method, f.because
    from facts f
    order by f.a_id, f.b_id, f.score desc, f.method
  ),
  kinds as (
    select f.a_id, f.b_id, array_agg(f.method order by f.score desc, f.method) as evidence
    from facts f
    group by f.a_id, f.b_id
  ),
  -- What names each contact of a pair: the rows a merge would move most of.
  named as (
    select x.id, c.created_at,
           ((select count(*) from entry_lines l where l.contact_id = x.id and l.company_id = p_company_id)
            + (select count(*) from documents d where d.contact_id = x.id and d.company_id = p_company_id))::integer as named_rows
    from (select a_id as id from best union select b_id from best) x
    join contacts c on c.id = x.id
  ),
  ranked as (
    select b.*, k.evidence,
           na.named_rows as a_rows, nb.named_rows as b_rows,
           (na.named_rows > nb.named_rows
            or (na.named_rows = nb.named_rows and (na.created_at, b.a_id) <= (nb.created_at, b.b_id))) as a_kept
    from best b
    join kinds k on k.a_id = b.a_id and k.b_id = b.b_id
    join named na on na.id = b.a_id
    join named nb on nb.id = b.b_id
  )
  select case when r.a_kept then r.a_id else r.b_id end,
         case when r.a_kept then ca.name else cb.name end,
         case when r.a_kept then r.b_id else r.a_id end,
         case when r.a_kept then cb.name else ca.name end,
         r.score, r.method, r.because, r.evidence,
         case when r.a_kept then r.a_rows else r.b_rows end,
         case when r.a_kept then r.b_rows else r.a_rows end
  from ranked r
  join contacts ca on ca.id = r.a_id
  join contacts cb on cb.id = r.b_id
  order by r.score desc,
           case when r.a_kept then ca.name else cb.name end,
           case when r.a_kept then cb.name else ca.name end;
end;
$$;

comment on function suggest_contact_duplicates(uuid) is
  'The pairs of contacts of a company that are probably one party (decision 0075), each once, strongest first: an identifier both carry — the same VAT number, registration number or bank account — scores 1; the same name 0.950; the words of one name all inside the other''s, in any order, 0.900 — the scale of contact_candidates(). A pair merge_contacts() would refuse — two different VAT or registration numbers, a contact merged or inactive — is not proposed. Each row proposes the contact more ledger lines and documents name as the one to keep (keep_id), the older on a tie, with the strongest evidence in a sentence and every kind of evidence found. It writes nothing and decides nothing: merge_contacts() joins a pair once a person has chosen.';

revoke execute on function suggest_contact_duplicates(uuid) from public, anon;
grant execute on function suggest_contact_duplicates(uuid) to authenticated, service_role;
