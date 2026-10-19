-- Ekwo OS — the contacts that are probably one party are proposed (decision
-- 0075).
--
-- `merge_contacts()` (decision 0074) joins two contacts once somebody has
-- said which two. Books taken over in two passes leave dozens of such pairs,
-- and nobody reads two thousand contacts side by side to find them.
-- `suggest_duplicate_contacts(company)` reads them for that person: one row
-- per probable pair of active contacts of the company, strongest first, with
-- which one to keep, the score, the kinds of evidence and the evidence in
-- sentences. It writes nothing and decides nothing; `merge_contacts()` is
-- still the act, and still asked by a person.
--
-- **The evidence is what the books already recognise a party by.**
--
--   * The same VAT number, the same registration number — identifiers,
--     compared once punctuation and case are set aside: score 1.
--   * The same bank account, on the contact or in a learned motif
--     (`counterparty_account`) — the evidence `contact_candidates()` already
--     scores 1: score 1.
--   * The same significant words of the name, in any order, or every word of
--     one name in the other ("Dupont" and "Dupont Holdings"). The words are
--     `significant_words()` at the company's minimum length, and the score is
--     the one `contact_candidates()` gives a name: 0.950 for the same name,
--     0.900 for the words of one inside the other, capped at 0.600 when the
--     words of the shorter name reach several contacts — then it cannot say
--     which one is the twin. A pair that merely shares a word is not
--     proposed: thirty suppliers whose names end in one legal form are not
--     thirty duplicates.
--
-- **One scoring path.** The score of a name and its cap are moved out of
-- `contact_candidates()` into `name_agreement()` and `name_among_several()`,
-- which `contact_candidates()` now calls, as this function does: a statement
-- line, a ledger line and a pair of contacts are weighed by one rule. The
-- normalisation of a bank account (`account_key()`) and of a VAT or
-- registration number (`party_identifier()`) are moved out the same way, so
-- that `merge_contacts()` refuses `different_identifiers` on exactly the
-- numbers this function treats as different — a pair with two different
-- numbers is never proposed, since the merge would refuse it.
--
-- **Which one to keep.** The one more of the books name — ledger lines and
-- documents — then the older, then the smaller id, so the answer is the same
-- at every call.
--
-- **Never proposed:** a pair across two companies, a contact inactive or
-- already merged, a contact and its own parent or branch, two contacts that
-- carry different VAT or registration numbers.
--
-- **Bounded.** The candidate pairs of a name are found through the rarest
-- word of each name — every word of one name is in the other, so its rarest
-- one is — and not by comparing every contact with every other: a word shared
-- by a thousand contacts costs nothing when each has a rarer one. The
-- identifiers are joined on their value, and the function plans hash joins
-- whatever the statistics say. About 40 ms at 2 000 contacts on PGlite
-- (`tests/duplicate_contacts.test.ts` holds it under 8 s).
--
-- Security invoker: the contacts, motifs, lines and documents read are those
-- the caller may read; a company of somebody else gives no row.

-- ---------------------------------------------------------------------------
-- 1. What a party is recognised by, normalised once
-- ---------------------------------------------------------------------------

create or replace function party_identifier(p_number text)
returns text
language sql
immutable
as $$
  select nullif(upper(regexp_replace(coalesce(p_number, ''), '[^0-9A-Za-z]', '', 'g')), '');
$$;

comment on function party_identifier(text) is
  'A VAT or registration number as two of them are compared: letters and digits only, upper case; null when nothing is left. Read by merge_contacts() to refuse different_identifiers and by suggest_duplicate_contacts() to propose a pair, so the two never disagree on what is one number.';

revoke execute on function party_identifier(text) from public, anon;
grant execute on function party_identifier(text) to authenticated, service_role;

create or replace function account_key(p_account text)
returns text
language sql
immutable
as $$
  select nullif(upper(replace(p_account, ' ', '')), '');
$$;

comment on function account_key(text) is
  'A bank account as two of them are compared: without spaces, upper case; null when nothing is left. Read by contact_candidates() and suggest_duplicate_contacts().';

revoke execute on function account_key(text) from public, anon;
grant execute on function account_key(text) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 2. The score of a name, moved out of contact_candidates()
-- ---------------------------------------------------------------------------

create or replace function name_agreement(p_text text, p_words text[], p_name text, p_name_words text[])
returns numeric
language sql
immutable
as $$
  -- From the shape that says the most to the one that says the least: the
  -- text is the whole name; every word of one is in the other; some words are
  -- shared, scored by how much of the shorter they cover.
  select
    case
      when lower(trim(p_name)) = lower(trim(coalesce(p_text, ''))) then 0.950
      when cardinality(p_name_words) > 0 and p_name_words <@ p_words then 0.900
      when cardinality(p_name_words) > 0 and p_words <@ p_name_words then 0.900
      when cardinality(array(select unnest(p_name_words) intersect select unnest(p_words))) > 0 then
        0.650 + 0.250 * (
          cardinality(array(select unnest(p_name_words) intersect select unnest(p_words)))::numeric
          / least(cardinality(p_name_words), cardinality(p_words))
        )
      else null
    end;
$$;

comment on function name_agreement(text, text[], text, text[]) is
  'How far a text agrees with a contact''s name, from their significant_words(): 0.950 when the text is the whole name, 0.900 when every word of one is in the other, 0.650 to 0.900 by the share of the shorter that the two have in common, null when they share nothing. The one score of a name, read by contact_candidates() and suggest_duplicate_contacts().';

revoke execute on function name_agreement(text, text[], text, text[]) from public, anon;
grant execute on function name_agreement(text, text[], text, text[]) to authenticated, service_role;

create or replace function name_among_several(p_score numeric, p_reached bigint)
returns numeric
language sql
immutable
as $$
  select case when p_reached > 1 and p_score < 0.950 then least(p_score, 0.600) else p_score end;
$$;

comment on function name_among_several(numeric, bigint) is
  'The score of a name once it is known how many contacts the same words reached (decision 0072): capped at 0.600 when they reached more than one, unless the text is the whole name (0.950). Read by contact_candidates() and suggest_duplicate_contacts().';

revoke execute on function name_among_several(numeric, bigint) from public, anon;
grant execute on function name_among_several(numeric, bigint) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 3. contact_candidates — `20261018210500`, through the functions above
-- ---------------------------------------------------------------------------

create or replace function contact_candidates(
  p_company_id     uuid,
  p_where          text,
  p_name           text,
  p_description    text,
  p_words          text,
  p_account        text,
  p_amount         numeric,
  p_currency       char(3),
  p_document_types doc_type[] default null
)
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
  v_policy matching_policy;
  v_words  text[];
  v_tokens text[];
begin
  v_policy := matching_policy_of(p_company_id);
  v_words  := significant_words(p_words, v_policy.minimum_word_length);

  -- The pieces of the text a document number could be: split on what no
  -- number is written with, the punctuation around them trimmed, as long as a
  -- word has to be to count and with a digit in them — a number is not a word.
  if p_document_types is not null then
    v_tokens := array(
      select distinct t.token
      from regexp_split_to_table(lower(coalesce(p_description, '')), '[^[:alnum:]/._-]+') as raw(piece)
      cross join lateral (select btrim(raw.piece, '/._-') as token) t
      where length(t.token) >= v_policy.minimum_word_length
        and t.token ~ '[0-9]'
    );
  end if;

  return query
  with
  -- 1. The account the money moved from or to. An account identifier is not a
  --    resemblance: either the line carried the one recorded against the
  --    contact, or it did not. Hence a score of 1, and the only evidence that
  --    needs no threshold.
  by_account as (
    select c.id, 1::numeric as score, 'account'::text as method,
           format('%s carries the account recorded against %s', p_where, c.name) as because
    from contacts c
    where c.company_id = p_company_id
      and p_account is not null
      and c.iban is not null
      and account_key(c.iban) = account_key(p_account)
    union
    select p.contact_id, 1::numeric, 'account',
           format('a motif of %s carries this account', c.name)
    from contact_patterns p
    join contacts c on c.id = p.contact_id
    where p.company_id = p_company_id
      and p.active
      and p.kind = 'counterparty_account'
      and p_account is not null
      and account_key(p.value) = account_key(p_account)
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
    where p.company_id = p_company_id
      and p.active
      and case p.kind
            when 'name_variation' then
              p_name is not null
              and lower(trim(p_name)) = lower(trim(p.value))
            when 'description_keyword' then
              p_description is not null
              and position(lower(p.value) in lower(p_description)) > 0
              and not exists (
                select 1 from unnest(coalesce(p.exclude_words, '{}'::text[])) as x(word)
                where position(lower(x.word) in lower(p_description)) > 0
              )
            when 'amount_range' then
              p.currency_code = p_currency
              and abs(p_amount) between p.amount_min and p.amount_max
            else false
          end
  ),
  -- 3. The number of a document of the company, of the types asked for: its
  --    own number, the supplier's number of a purchase, the reference its
  --    payment quotes. A number is an identification, not a resemblance — it
  --    names the document, and the document names its contact — so it scores
  --    just under an account. One row per contact: two documents of one
  --    contact are one piece of evidence, two contacts are a coincidence.
  by_document as (
    select distinct on (d.contact_id)
           d.contact_id as id, 0.980::numeric as score, 'document'::text as method,
           format('%s names %s %s of %s', p_where, replace(d.doc_type::text, '_', ' '), r.ref, c.name) as because
    from documents d
    join contacts c on c.id = d.contact_id and c.company_id = d.company_id
    cross join lateral (values (d.number), (d.supplier_reference), (d.payment_reference)) as r(ref)
    where d.company_id = p_company_id
      and cardinality(coalesce(v_tokens, '{}'::text[])) > 0
      and d.doc_type = any(p_document_types)
      and r.ref is not null
      and lower(btrim(r.ref, '+*/._- ')) = any(v_tokens)
    order by d.contact_id, d.document_date desc nulls last, d.id
  ),
  -- 4. The name, compared word by word. Three shapes, from the one that says
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
        name_agreement(p_name, v_words, c.name, w.words) as score,
        format('the name on %s shares %s with %s',
               p_where,
               array_to_string(array(select unnest(w.words) intersect select unnest(v_words)), ', '),
               c.name) as because
    ) s
    where c.company_id = p_company_id
      and c.active
      and cardinality(v_words) > 0
      -- A contact whose name shares no word with the line scores nothing
      -- below, so it is set aside here, by an array operator on a stored
      -- column, before anything is worked out about it (`20260918143352`).
      and c.name_words && v_words
      and s.score is not null
      and s.score >= v_policy.name_threshold
  ),
  -- A text whose words reach several contacts names none of them for sure
  -- (decision 0072): each is capped at 0.600, below what a single name earns,
  -- and says how many the text reached. A label that is a contact's whole
  -- name is that contact, and keeps its 0.950.
  by_name_among as (
    select n.id,
           name_among_several(n.score, count(*) over ()) as score,
           n.method,
           case when count(*) over () > 1 and n.score < 0.950
                then format('%s; the text reaches %s contacts by name', n.because, count(*) over ())
                else n.because end as because
    from by_name n
  ),
  all_candidates as (
    select * from by_account
    union all select * from by_pattern
    union all select * from by_document
    union all select * from by_name_among
  )
  select a.id, a.score, a.method, a.because,
         count(*) over (partition by a.method)::integer
  from all_candidates a
  order by a.score desc, a.method;
end;
$$;

comment on function contact_candidates(uuid, text, text, text, text, text, numeric, char, doc_type[]) is
  'The one scoring of a counterparty, for whatever line carries the facts: the account it moved on, the motifs of contact_patterns, the number of a document of the types named (none named, none looked for), and the words of a contact''s name — capped at 0.600 when the words reach several contacts, unless the label is a contact''s whole name. Each candidate with its score, the evidence in a sentence and how many contacts that same evidence reached. Read by suggest_contacts() for a statement line and by suggest_line_contacts() for a ledger line; it writes nothing and decides nothing.';

-- ---------------------------------------------------------------------------
-- 4. merge_contacts — `20261019090000`, comparing numbers through
--    party_identifier()
-- ---------------------------------------------------------------------------

create or replace function merge_contacts(p_keep uuid, p_absorb uuid)
returns contact_merges
language plpgsql
volatile
security definer
set search_path = public, pg_temp
as $$
declare
  v_keep     contacts;
  v_absorb   contacts;
  v_new      contacts;
  v_company  uuid;
  v_filled   text[] := '{}';
  v_moved    jsonb := '{}';
  v_folded   integer := 0;
  v_pmoved   integer := 0;
  v_n        integer;
  v_chain    uuid;
  v_depth    integer;
  r          record;
  v_twin     uuid;
  v_bad      record;
  v_merge    uuid;
  v_record   contact_merges;
begin
  -- A contact the caller may not read is a contact that does not exist, here
  -- as under row level security.
  select * into v_keep from contacts c where c.id = p_keep;
  if not found or not (is_installer() or has_capability(v_keep.company_id, 'contacts.read')) then
    raise exception 'unknown_contact: no contact %', p_keep
      using errcode = 'no_data_found';
  end if;
  v_company := v_keep.company_id;

  if not is_installer() and not has_capability(v_company, 'contacts.write') then
    raise exception 'not_allowed: merging two contacts in this company needs contacts.write'
      using errcode = '42501';
  end if;
  if not is_installer() and not has_capability(v_company, 'reconcile.write') then
    raise exception 'not_allowed: merging two contacts in this company needs reconcile.write, since it restates who each of their items belongs to'
      using errcode = '42501';
  end if;

  if p_absorb is not distinct from p_keep then
    raise exception 'same_contact: % is one contact, and a merge joins two', v_keep.name
      using errcode = '22023';
  end if;

  select * into v_absorb from contacts c where c.id = p_absorb and c.company_id = v_company;
  if not found then
    raise exception 'unknown_contact: no contact % in the company of %', p_absorb, v_keep.name
      using errcode = 'no_data_found';
  end if;


  -- Two merges of one contact wait for each other, in one order whoever asks.
  perform 1 from contacts c where c.id in (p_keep, p_absorb) order by c.id for update;
  select * into v_keep from contacts c where c.id = p_keep;
  select * into v_absorb from contacts c where c.id = p_absorb;

  if v_absorb.merged_into is not null then
    raise exception 'already_merged: % was merged into % before, and has nothing left to move',
      v_absorb.name, coalesce((select k.name from contacts k where k.id = v_absorb.merged_into), v_absorb.merged_into::text)
      using errcode = '55006';
  end if;
  if v_keep.merged_into is not null then
    raise exception 'already_merged: % was merged into % (%), which holds its history: merge into that one',
      v_keep.name, coalesce((select k.name from contacts k where k.id = v_keep.merged_into), v_keep.merged_into::text),
      v_keep.merged_into
      using errcode = '55006';
  end if;

  -- Two numbers are two legal persons, whatever their names say; and a
  -- declaration reads the number.
  if party_identifier(v_keep.vat_number) <> party_identifier(v_absorb.vat_number) then
    raise exception 'different_identifiers: % carries the VAT number % and % carries %: two numbers are two parties, and are not merged',
      v_keep.name, v_keep.vat_number, v_absorb.name, v_absorb.vat_number
      using errcode = '55006';
  end if;
  if party_identifier(v_keep.registration_number) <> party_identifier(v_absorb.registration_number) then
    raise exception 'different_identifiers: % carries the registration number % and % carries %: two numbers are two parties, and are not merged',
      v_keep.name, v_keep.registration_number, v_absorb.name, v_absorb.registration_number
      using errcode = '55006';
  end if;

  -- -------------------------------------------------------------------------
  -- The kept contact, completed and never overwritten
  -- -------------------------------------------------------------------------
  v_new := v_keep;

  if coalesce(btrim(v_new.vat_number), '') = '' and coalesce(btrim(v_absorb.vat_number), '') <> '' then
    v_new.vat_number := v_absorb.vat_number; v_filled := v_filled || 'vat_number'::text;
  end if;
  if coalesce(btrim(v_new.registration_number), '') = '' and coalesce(btrim(v_absorb.registration_number), '') <> '' then
    v_new.registration_number := v_absorb.registration_number; v_filled := v_filled || 'registration_number'::text;
  end if;
  if coalesce(btrim(v_new.auxiliary_code), '') = '' and coalesce(btrim(v_absorb.auxiliary_code), '') <> '' then
    v_new.auxiliary_code := v_absorb.auxiliary_code; v_filled := v_filled || 'auxiliary_code'::text;
  end if;
  if coalesce(btrim(v_new.email), '') = '' and coalesce(btrim(v_absorb.email), '') <> '' then
    v_new.email := v_absorb.email; v_filled := v_filled || 'email'::text;
  end if;
  if coalesce(btrim(v_new.phone), '') = '' and coalesce(btrim(v_absorb.phone), '') <> '' then
    v_new.phone := v_absorb.phone; v_filled := v_filled || 'phone'::text;
  end if;
  if v_new.language is null and v_absorb.language is not null then
    v_new.language := v_absorb.language; v_filled := v_filled || 'language'::text;
  end if;
  if v_new.currency_code is null and v_absorb.currency_code is not null then
    v_new.currency_code := v_absorb.currency_code; v_filled := v_filled || 'currency_code'::text;
  end if;
  if v_new.receivable_account_id is null and v_absorb.receivable_account_id is not null then
    v_new.receivable_account_id := v_absorb.receivable_account_id; v_filled := v_filled || 'receivable_account_id'::text;
  end if;
  if v_new.payable_account_id is null and v_absorb.payable_account_id is not null then
    v_new.payable_account_id := v_absorb.payable_account_id; v_filled := v_filled || 'payable_account_id'::text;
  end if;
  if coalesce(btrim(v_new.notes), '') = '' and coalesce(btrim(v_absorb.notes), '') <> '' then
    v_new.notes := v_absorb.notes; v_filled := v_filled || 'notes'::text;
  end if;

  -- The postal address is one fact: taken whole, where the kept contact has
  -- none, and not from another country than the one it already names.
  if coalesce(btrim(v_new.address_line1), '') = '' and coalesce(btrim(v_new.address_line2), '') = ''
     and coalesce(btrim(v_new.postal_code), '') = '' and coalesce(btrim(v_new.city), '') = ''
     and coalesce(btrim(v_new.region), '') = ''
     and (coalesce(btrim(v_absorb.address_line1), '') <> '' or coalesce(btrim(v_absorb.city), '') <> ''
          or coalesce(btrim(v_absorb.postal_code), '') <> '')
     and (v_new.country is null or v_absorb.country is null or v_new.country = v_absorb.country) then
    v_new.address_line1 := v_absorb.address_line1;
    v_new.address_line2 := v_absorb.address_line2;
    v_new.postal_code   := v_absorb.postal_code;
    v_new.city          := v_absorb.city;
    v_new.region        := v_absorb.region;
    v_filled := v_filled || array['address_line1', 'address_line2', 'postal_code', 'city', 'region'];
  end if;
  if v_new.country is null and v_absorb.country is not null then
    v_new.country := v_absorb.country;
    v_new.territory_code := coalesce(v_new.territory_code, v_absorb.territory_code);
    v_filled := v_filled || array['country', 'territory_code'];
  end if;

  -- A bank account and its BIC, an electronic address and its scheme: the
  -- one without the other is somebody else's.
  if coalesce(btrim(v_new.iban), '') = '' and coalesce(btrim(v_absorb.iban), '') <> '' then
    v_new.iban := v_absorb.iban;
    v_new.bic  := v_absorb.bic;
    v_filled := v_filled || array['iban', 'bic'];
  end if;
  if coalesce(btrim(v_new.peppol_identifier), '') = '' and coalesce(btrim(v_absorb.peppol_identifier), '') <> '' then
    v_new.peppol_scheme     := v_absorb.peppol_scheme;
    v_new.peppol_identifier := v_absorb.peppol_identifier;
    v_filled := v_filled || array['peppol_scheme', 'peppol_identifier'];
  end if;

  -- A customer who is also a supplier is both; a contact nobody typed takes
  -- the type of the one it absorbs.
  if v_new.contact_type = 'other' and v_absorb.contact_type <> 'other' then
    v_new.contact_type := v_absorb.contact_type; v_filled := v_filled || 'contact_type'::text;
  elsif v_new.contact_type in ('customer', 'supplier')
        and v_absorb.contact_type in ('customer', 'supplier', 'both')
        and v_absorb.contact_type <> v_new.contact_type then
    v_new.contact_type := 'both'; v_filled := v_filled || 'contact_type'::text;
  end if;

  -- The parent. A branch of the absorbed contact that is the kept one goes up
  -- to the absorbed contact's own parent; a kept contact with no parent takes
  -- the absorbed one's, unless that parent is below the kept contact.
  if v_new.parent_id = p_absorb then
    v_new.parent_id := v_absorb.parent_id;
  end if;
  if v_new.parent_id is null and v_absorb.parent_id is not null and v_absorb.parent_id <> p_keep then
    v_chain := v_absorb.parent_id;
    v_depth := 0;
    while v_chain is not null and v_chain <> p_keep and v_depth <= 32 loop
      select c.parent_id into v_chain from contacts c where c.id = v_chain and c.company_id = v_company;
      v_depth := v_depth + 1;
    end loop;
    if v_chain is null then
      v_new.parent_id := v_absorb.parent_id; v_filled := v_filled || 'parent_id'::text;
    end if;
  end if;

  -- An auxiliary code is unique in the company: the absorbed contact gives
  -- its own up before the kept one takes it.
  if 'auxiliary_code' = any (v_filled) then
    update contacts c set auxiliary_code = null where c.id = p_absorb;
  end if;

  update contacts c
     set vat_number            = v_new.vat_number,
         registration_number   = v_new.registration_number,
         auxiliary_code        = v_new.auxiliary_code,
         email                 = v_new.email,
         phone                 = v_new.phone,
         language              = v_new.language,
         currency_code         = v_new.currency_code,
         receivable_account_id = v_new.receivable_account_id,
         payable_account_id    = v_new.payable_account_id,
         notes                 = v_new.notes,
         address_line1         = v_new.address_line1,
         address_line2         = v_new.address_line2,
         postal_code           = v_new.postal_code,
         city                  = v_new.city,
         region                = v_new.region,
         country               = v_new.country,
         territory_code        = v_new.territory_code,
         iban                  = v_new.iban,
         bic                   = v_new.bic,
         peppol_scheme         = v_new.peppol_scheme,
         peppol_identifier     = v_new.peppol_identifier,
         contact_type          = v_new.contact_type,
         parent_id             = v_new.parent_id
   where c.id = p_keep
     and (v_filled <> '{}' or c.parent_id is distinct from v_new.parent_id);

  -- -------------------------------------------------------------------------
  -- Every reference, read from the catalogue
  -- -------------------------------------------------------------------------
  -- The record the guards read: in this transaction, and only for these two.
  insert into contact_merges (company_id, kept_id, absorbed_id, merged_by)
  values (v_company, p_keep, p_absorb, acting_user())
  returning id into v_merge;

  for r in
    select c.conrelid::regclass as tbl, a.attname
      from pg_constraint c
      join unnest(c.conkey) as k(attnum) on true
      join pg_attribute a on a.attrelid = c.conrelid and a.attnum = k.attnum
     where c.contype = 'f'
       and c.confrelid = 'public.contacts'::regclass
       and a.attname <> 'company_id'
       -- By name, below: the contacts themselves and the learned motifs; and
       -- the record of the merges, which says what happened and stays.
       and c.conrelid not in ('public.contacts'::regclass, 'public.contact_patterns'::regclass,
                              'public.contact_merges'::regclass)
     order by c.conrelid::regclass::text, a.attname
  loop
    execute format('update %s set %I = $1 where %I = $2 and company_id = $3', r.tbl, r.attname, r.attname)
      using p_keep, p_absorb, v_company;
    get diagnostics v_n = row_count;
    if v_n > 0 then
      v_moved := v_moved || jsonb_build_object(
        case when r.attname = 'contact_id' then r.tbl::text else r.tbl::text || '.' || r.attname end, v_n);
    end if;
  end loop;

  -- The branches of the absorbed contact are branches of the kept one.
  update contacts c set parent_id = p_keep
   where c.company_id = v_company and c.parent_id = p_absorb and c.id <> p_keep;
  get diagnostics v_n = row_count;
  if v_n > 0 then
    v_moved := v_moved || jsonb_build_object('contacts.parent_id', v_n);
  end if;

  -- The files attached to the contact, which name it by entity, not by key.
  update attachments a set entity_id = p_keep
   where a.company_id = v_company and a.entity_type = 'contact' and a.entity_id = p_absorb;
  get diagnostics v_n = row_count;
  if v_n > 0 then
    v_moved := v_moved || jsonb_build_object('attachments', v_n);
  end if;

  -- The learned motifs, folded: one motif the two had is one motif with both
  -- histories, and its confidence is what the two counters say together.
  for r in
    select * from contact_patterns p
     where p.company_id = v_company and p.contact_id = p_absorb
     order by p.created_at, p.id
  loop
    select t.id into v_twin
      from contact_patterns t
     where t.company_id = v_company and t.contact_id = p_keep and t.kind = r.kind
       and ((r.value is not null and t.value = r.value)
            or (r.value is null and t.value is null
                and t.amount_min = r.amount_min and t.amount_max = r.amount_max
                and t.currency_code = r.currency_code))
     for update;
    if found then
      update contact_patterns t
         set usage_count     = t.usage_count + r.usage_count,
             success_count   = t.success_count + r.success_count,
             confidence      = (t.success_count + r.success_count + 1)::numeric
                               / (t.usage_count + r.usage_count + 2),
             last_matched_at = greatest(t.last_matched_at, r.last_matched_at),
             amount_typical  = coalesce(t.amount_typical, r.amount_typical),
             exclude_words   = case when t.exclude_words is null and r.exclude_words is null then null
                                    else array(select distinct w
                                                 from unnest(coalesce(t.exclude_words, '{}') || coalesce(r.exclude_words, '{}')) w
                                                order by w) end,
             -- A motif somebody wrote down is an instruction, whoever learned it too.
             source          = case when 'declared' in (t.source, r.source) then 'declared' else 'learned' end::contact_pattern_source,
             active          = t.active or r.active
       where t.id = v_twin;
      delete from contact_patterns p where p.id = r.id;
      v_folded := v_folded + 1;
    else
      update contact_patterns p set contact_id = p_keep where p.id = r.id;
      v_pmoved := v_pmoved + 1;
    end if;
  end loop;
  if v_pmoved > 0 then
    v_moved := v_moved || jsonb_build_object('contact_patterns', v_pmoved);
  end if;
  if v_folded > 0 then
    v_moved := v_moved || jsonb_build_object('contact_patterns_folded', v_folded);
  end if;

  -- -------------------------------------------------------------------------
  -- The absorbed contact, retired
  -- -------------------------------------------------------------------------
  update contacts c set active = false, merged_into = p_keep where c.id = p_absorb;

  -- A contact merged into the absorbed one before follows it, so that
  -- merged_into always names a contact in use.
  update contacts c set merged_into = p_keep
   where c.company_id = v_company and c.merged_into = p_absorb;
  get diagnostics v_n = row_count;
  if v_n > 0 then
    v_moved := v_moved || jsonb_build_object('contacts.merged_into', v_n);
  end if;

  -- Every matching of the kept party's items is still of one party: both
  -- lines in its tree, or one of them naming nobody.
  with recursive party(id) as (
    select commercial_entity(p_keep)
    union
    select c.id from contacts c join party p on c.parent_id = p.id where c.company_id = v_company
  )
  select rc.matching_number, d.id as debit_id, k.id as credit_id,
         case when d.contact_id in (select id from party) then k.contact_id else d.contact_id end as other
    into v_bad
    from reconciliations rc
    join entry_lines d on d.id = rc.debit_line_id and d.company_id = rc.company_id
    join entry_lines k on k.id = rc.credit_line_id and k.company_id = rc.company_id
   where rc.company_id = v_company
     and d.contact_id is not null and k.contact_id is not null
     and (d.contact_id in (select id from party)) <> (k.contact_id in (select id from party))
   limit 1;
  if found then
    raise exception 'matching_across_parties: once % is merged into %, matching % would settle lines % and % of two parties — % is not of %''s party. Undo that matching first, with unreconcile(), or give the two contacts one parent.',
      v_absorb.name, v_keep.name, coalesce(v_bad.matching_number, '?'), v_bad.debit_id, v_bad.credit_id,
      coalesce((select c.name from contacts c where c.id = v_bad.other), v_bad.other::text), v_keep.name
      using errcode = '55006';
  end if;

  select * into v_keep from contacts c where c.id = p_keep;
  select * into v_absorb from contacts c where c.id = p_absorb;

  update contact_merges m set moved = v_moved, filled = v_filled where m.id = v_merge
  returning * into v_record;

  perform audit_record(
    v_company, 'contacts', p_absorb, v_absorb.name,
    'update', 'contacts_merged',
    jsonb_build_object('merged_into', null),
    jsonb_build_object('merged_into', p_keep, 'kept', v_keep.name, 'moved', v_moved, 'filled', to_jsonb(v_filled)));

  return v_record;
end;
$$;

-- ---------------------------------------------------------------------------
-- 5. suggest_duplicate_contacts
-- ---------------------------------------------------------------------------

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
  -- The contacts that may still be merged: active, merged into nobody.
  pool as materialized (
    select c.id, c.name, c.created_at, c.parent_id,
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
  -- 2. The name. A pair is two contacts whose names are the same, or where
  --    every significant word of one is in the other. Every word of the
  --    shorter is in the longer, its rarest word too, so the candidates of
  --    each contact are the holders of its rarest word.
  holders as (
    select p.id, u.word
    from pool p cross join lateral unnest(p.words) as u(word)
  ),
  reach as (
    select h.word, count(*) as contacts from holders h group by h.word
  ),
  rarest as (
    select distinct on (h.id) h.id, h.word
    from holders h join reach r on r.word = h.word
    order by h.id, r.contacts, h.word
  ),
  -- Directed: the words of `a` are all in the name of `b`.
  name_pairs as (
    select r.id as a_id, h.id as b_id
    from rarest r
    join holders h on h.word = r.word and h.id <> r.id
    join pool a on a.id = r.id
    join pool b on b.id = h.id
    where a.words <@ b.words
    union
    -- The same name with no word long enough to count still names one party.
    select a.id, b.id
    from pool a
    join pool b on lower(trim(b.name)) = lower(trim(a.name)) and b.id <> a.id
  ),
  named as (
    select n.a_id, n.b_id, a.name as a_name, b.name as b_name, a.words, b.words as b_words,
           name_agreement(a.name, a.words, b.name, b.words) as agreement,
           -- How many contacts the words of `a` reach, as contact_candidates()
           -- counts what a text reaches.
           count(*) over (partition by n.a_id) as reached
    from name_pairs n
    join pool a on a.id = n.a_id
    join pool b on b.id = n.b_id
  ),
  by_name as (
    select least(n.a_id, n.b_id) as lo, greatest(n.a_id, n.b_id) as hi, 'name'::text as kind,
           name_among_several(n.agreement, n.reached) as score,
           case
             when n.agreement >= 0.950 then format('%s and %s carry the same name', n.a_name, n.b_name)
             when n.words @> n.b_words then format('%s and %s carry the same words: %s', n.a_name, n.b_name,
                                                   array_to_string(array(select unnest(n.words) order by 1), ', '))
             else format('every word of %s is in %s', n.a_name, n.b_name)
           end
           || case when n.reached > 1 and n.agreement < 0.950
                   then format('; the words of %s are in the names of %s contacts', n.a_name, n.reached)
                   else '' end as because
    from named n
    where n.agreement is not null
      and name_among_several(n.agreement, n.reached) >= v_policy.name_threshold
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
  'The contacts of a company that are probably one party (decision 0075): one row per pair of active contacts merged into nobody, strongest first — keep_id, the one more ledger lines and documents name (then the older), absorb_id, score from 0 to 1, evidence (the kinds, strongest first, comma-separated: vat_number, registration_number, account, name) and because (the evidence in sentences). The same VAT or registration number (party_identifier()) and the same bank account on the contact or in a learned motif (account_key()) score 1; the same significant words of the name in any order, or every word of one in the other, score as contact_candidates() scores a name (name_agreement(), capped by name_among_several() when the words reach several contacts), from the company''s matching policy. A pair across companies, with two different VAT or registration numbers, or of a contact and its own parent is never proposed. It writes nothing and decides nothing; merge_contacts() joins a pair a person chose.';

revoke execute on function suggest_duplicate_contacts(uuid) from public, anon;
grant execute on function suggest_duplicate_contacts(uuid) to authenticated, service_role;
