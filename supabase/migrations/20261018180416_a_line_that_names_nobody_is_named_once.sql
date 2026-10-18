-- Ekwo OS — a third-party line that names nobody is named once (decision 0070).
--
-- Books brought in line by line from another system arrive with open items on
-- the receivable and payable accounts that name no contact: "Invoice 25010013
-- - Acme", "Salary 04", the opening of the payables in one amount. Matching
-- settles the items of one counterparty, the aged balance groups by it, and a
-- line that names nobody is answered by neither. Since `20260918161538` the
-- contact of a posted line is frozen with the rest of it, so nobody could say
-- who it is short of reversing an entry that was never wrong.
--
-- Four things, and one rule underneath them: **one scoring path, one learning
-- path.** Statement lines already had both — `suggest_contacts()` and
-- `confirm_contact()`, `20260917090000` and `20260918143352`. They are not
-- copied here. Their bodies become two functions that take the facts a line
-- carries rather than a statement line, and the two old functions call them
-- with the facts of a statement line:
--
--   * `contact_candidates()` — the account, the motifs, the words of a name,
--     and one piece of evidence a ledger line carries more often than a
--     statement: the number of a document of the company. It is asked for by
--     naming the document types to look in, and `suggest_contacts()` names
--     none, so what a statement line is told is what it was told yesterday —
--     the same rows, the same scores, the same sentences, the same counts;
--     `tests/contact_matching.test.ts` is unchanged and passes.
--   * `learn_contact_patterns()` — what `confirm_contact()` learned, from the
--     same inputs: every motif that named somebody else is charged a use, the
--     account and the name as written become motifs of the contact chosen.
--
-- Then the two functions of a ledger line:
--
--   * `suggest_line_contacts(company, lines)` — every open line on a
--     receivable or payable account that names nobody, with its candidates,
--     best first. The kind of the account is `account_type`, which the pack
--     gives; no account code is read anywhere in this file.
--   * `set_line_contact(line, contact)` — names it, once, from null to a
--     contact of the same company, and learns.
--
-- **The guard of a posted line lets exactly that through, and nothing else.**
-- `entry_lines_guard_posted()` is replaced whole with one exemption: an update
-- that moves `contact_id` alone, from null to a value, on a line that is on a
-- receivable or payable account and matched in no part, while the setting
-- `ekwo.naming_line_contact` holds the id of *that* line — raised by
-- `set_line_contact()` around its one update — and for a caller holding
-- `reconcile.write`, because any session may raise a setting
-- (`20260929094126`). The installer passes, as everywhere. Every other column
-- is refused as before, and so is a second naming: the line names somebody
-- now. The conditions sit in the guard as well as in the function so that the
-- rule is the guard's, and the function is where a caller is told, by name,
-- which of them failed.
--
-- **The guard writes the trail.** The lines of a posted entry have none — the
-- posting is recorded and the lines are not, because they do not move — so
-- the one change that may happen to them is recorded where it is let through:
-- `line_contact_named`, the line, the contact, who. A naming that is not in
-- the trail cannot happen.
--
-- And `open_items()` takes `p_third_party_only`: the receivable and payable
-- lines alone, for a matching screen that has no use for the bank's own lines.
-- Left out, it answers what it answered.

-- ---------------------------------------------------------------------------
-- 1. contact_candidates — the scoring of `20260918143352`, for any line
-- ---------------------------------------------------------------------------

create or replace function contact_candidates(
  p_company_id     uuid,
  -- What the sentences call the line: 'the statement', 'the line'.
  p_where          text,
  -- The name as the line writes it: a statement's counterparty, a ledger
  -- line's label. Read by a `name_variation` motif and by the exact name.
  p_name           text,
  -- The free text: read by a `description_keyword` motif and searched for the
  -- number of a document.
  p_description    text,
  -- The text whose words are compared with the words of a contact's name.
  p_words          text,
  -- The account the money moved from or to, where the line carries one.
  p_account        text,
  p_amount         numeric,
  p_currency       char(3),
  -- The types of document whose number is evidence. Null: no document is
  -- looked for, which is what a statement line asks.
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
      and upper(replace(c.iban, ' ', '')) = upper(replace(p_account, ' ', ''))
    union
    select p.contact_id, 1::numeric, 'account',
           format('a motif of %s carries this account', c.name)
    from contact_patterns p
    join contacts c on c.id = p.contact_id
    where p.company_id = p_company_id
      and p.active
      and p.kind = 'counterparty_account'
      and p_account is not null
      and upper(replace(p.value, ' ', '')) = upper(replace(p_account, ' ', ''))
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
        case
          when lower(trim(c.name)) = lower(trim(coalesce(p_name, ''))) then 0.950
          when cardinality(w.words) > 0 and w.words <@ v_words then 0.900
          when cardinality(w.words) > 0 and v_words <@ w.words then 0.900
          when cardinality(array(select unnest(w.words) intersect select unnest(v_words))) > 0 then
            0.650 + 0.250 * (
              cardinality(array(select unnest(w.words) intersect select unnest(v_words)))::numeric
              / least(cardinality(w.words), cardinality(v_words))
            )
          else null
        end as score,
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
  all_candidates as (
    select * from by_account
    union all select * from by_pattern
    union all select * from by_document
    union all select * from by_name
  )
  select a.id, a.score, a.method, a.because,
         count(*) over (partition by a.method)::integer
  from all_candidates a
  order by a.score desc, a.method;
end;
$$;

comment on function contact_candidates(uuid, text, text, text, text, text, numeric, char, doc_type[]) is
  'The one scoring of a counterparty, for whatever line carries the facts: the account it moved on, the motifs of contact_patterns, the number of a document of the types named (none named, none looked for), and the words of a contact''s name. Each candidate with its score, the evidence in a sentence and how many contacts that same evidence reached. Read by suggest_contacts() for a statement line and by suggest_line_contacts() for a ledger line; it writes nothing and decides nothing.';

revoke execute on function contact_candidates(uuid, text, text, text, text, text, numeric, char, doc_type[]) from public, anon;
grant execute on function contact_candidates(uuid, text, text, text, text, text, numeric, char, doc_type[]) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 2. suggest_contacts — the same answer, through the one scoring
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
  v_tx bank_transactions;
begin
  -- Row level security answers this select, so a member of another company
  -- gets nothing and is told nothing.
  select * into v_tx from bank_transactions t where t.id = p_transaction_id;
  if not found then
    raise exception 'not_found: bank transaction %', p_transaction_id
      using errcode = 'no_data_found';
  end if;

  return query
  select * from contact_candidates(
    v_tx.company_id, 'the statement',
    v_tx.counterpart_name, v_tx.description,
    coalesce(v_tx.counterpart_name, v_tx.description),
    v_tx.counterpart_iban, v_tx.amount, v_tx.currency_code);
end;
$$;

comment on function suggest_contacts(uuid) is
  'Who this statement line could be, with the score, the evidence in a sentence, and how many contacts that same evidence reached — contact_candidates() with the facts of the line. It writes nothing and decides nothing: a caller that applies a match on its own is expected to require alternatives = 1.';

-- ---------------------------------------------------------------------------
-- 3. learn_contact_patterns — what `confirm_contact()` learned, for any line
-- ---------------------------------------------------------------------------

create or replace function learn_contact_patterns(
  p_company_id     uuid,
  p_contact_id     uuid,
  p_where          text,
  p_name           text,
  p_description    text,
  p_words          text,
  p_account        text,
  p_amount         numeric,
  p_currency       char(3),
  p_document_types doc_type[] default null
)
returns void
language plpgsql
volatile
security invoker
as $$
declare
  v_policy matching_policy := matching_policy_of(p_company_id);
begin
  -- Every motif that named somebody else has now been in front of a decision
  -- and lost it. Charged first, so that a motif that also named the right
  -- contact is not punished for it below.
  update contact_patterns p
     set usage_count = p.usage_count + 1,
         confidence  = (p.success_count + 1)::numeric / (p.usage_count + 3)
   where p.id in (
     select cp.id
     from contact_patterns cp
     join contact_candidates(p_company_id, p_where, p_name, p_description, p_words,
                             p_account, p_amount, p_currency, p_document_types) s
       on s.contact_id = cp.contact_id
      and s.method = 'pattern:' || cp.kind::text
     where cp.company_id = p_company_id
       and cp.contact_id <> p_contact_id
   );

  -- The account, when the line carried one. This is the motif worth the
  -- most, and the one a bank writes identically every time.
  if p_account is not null then
    insert into contact_patterns (company_id, contact_id, kind, value, source,
                                  usage_count, success_count, confidence, last_matched_at)
    values (p_company_id, p_contact_id, 'counterparty_account',
            upper(replace(p_account, ' ', '')), 'learned',
            1, 1, 2::numeric / 3, now())
    on conflict (company_id, contact_id, kind, value) where value is not null
    do update set usage_count     = contact_patterns.usage_count + 1,
                  success_count   = contact_patterns.success_count + 1,
                  confidence      = (contact_patterns.success_count + 2)::numeric
                                    / (contact_patterns.usage_count + 3),
                  last_matched_at = now(),
                  active          = true;
  end if;

  -- The name as this line writes it, which is rarely the name in the ledger.
  -- Stored only when it carries a word worth comparing: a line whose name is
  -- "PAIEMENT" teaches nothing.
  if p_name is not null
     and cardinality(significant_words(p_name, v_policy.minimum_word_length)) > 0
  then
    insert into contact_patterns (company_id, contact_id, kind, value, source,
                                  usage_count, success_count, confidence, last_matched_at)
    values (p_company_id, p_contact_id, 'name_variation',
            trim(p_name), 'learned', 1, 1, 2::numeric / 3, now())
    on conflict (company_id, contact_id, kind, value) where value is not null
    do update set usage_count     = contact_patterns.usage_count + 1,
                  success_count   = contact_patterns.success_count + 1,
                  confidence      = (contact_patterns.success_count + 2)::numeric
                                    / (contact_patterns.usage_count + 3),
                  last_matched_at = now(),
                  active          = true;
  end if;
end;
$$;

comment on function learn_contact_patterns(uuid, uuid, text, text, text, text, text, numeric, char, doc_type[]) is
  'What a decision teaches contact_patterns, from the same facts contact_candidates() scored: every motif that had named somebody else is charged a use without a success, and the account and the name as the line wrote them become learned motifs of the contact chosen. Called by confirm_contact() and set_line_contact(), the only two places a motif is learned.';

revoke execute on function learn_contact_patterns(uuid, uuid, text, text, text, text, text, numeric, char, doc_type[]) from public, anon;
grant execute on function learn_contact_patterns(uuid, uuid, text, text, text, text, text, numeric, char, doc_type[]) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 4. confirm_contact — the same learning, through the one path
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

  perform learn_contact_patterns(
    v_tx.company_id, p_contact_id, 'the statement',
    v_tx.counterpart_name, v_tx.description,
    coalesce(v_tx.counterpart_name, v_tx.description),
    v_tx.counterpart_iban, v_tx.amount, v_tx.currency_code);

  update bank_transactions t
     set contact_id = p_contact_id
   where t.id = p_transaction_id
  returning * into v_tx;

  return v_tx;
end;
$$;

comment on function confirm_contact(uuid, uuid) is
  'Attributes a statement line to a contact and learns from it, through learn_contact_patterns(): the account and the name as this bank writes them become motifs, and every motif that had named somebody else is charged a use without a success. Knowing who the money came from is not knowing what it pays — this function never touches a document and never reconciles anything.';

-- ---------------------------------------------------------------------------
-- 5. What a ledger line says about who it is
--
-- One place, so that the suggestion and the naming read a line the same way:
-- the label is the name as written; the label, the description of the entry
-- and its reference are the text; the amount is in the currency the line is
-- stated in. Which documents are evidence follows the side of the account — a
-- receivable is settled by a sale, a payable by a purchase — and the side is
-- the account's type, never its code.
-- ---------------------------------------------------------------------------

create or replace function line_contact_facts(p_line_id uuid)
returns table (
  line_id        uuid,
  company_id     uuid,
  name           text,
  content        text,
  amount         numeric,
  currency_code  char(3),
  document_types doc_type[]
)
language sql
stable
security invoker
as $$
  select l.id,
         l.company_id,
         l.name,
         nullif(concat_ws(' ', l.name, e.description, e.reference), ''),
         case when l.amount_currency is not null and l.currency_code is distinct from co.currency_code
              then abs(l.amount_currency) else abs(l.balance) end,
         case when l.amount_currency is not null and l.currency_code is distinct from co.currency_code
              then l.currency_code else co.currency_code end,
         case a.account_type
           when 'asset_receivable'  then array['sale_invoice', 'sale_credit_note', 'sale_quote']::doc_type[]
           when 'liability_payable' then array['purchase_invoice', 'purchase_credit_note', 'purchase_order']::doc_type[]
         end
  from entry_lines l
  join entries e   on e.id = l.entry_id and e.company_id = l.company_id
  join accounts a  on a.id = l.account_id and a.company_id = l.company_id
  join companies co on co.id = l.company_id
  where l.id = p_line_id;
$$;

comment on function line_contact_facts(uuid) is
  'What a ledger line says about who it is, as contact_candidates() reads it: the label, the text of the label, the entry''s description and reference, the amount in the currency the line is stated in, and the types of document whose number is evidence — sales for a receivable, purchases for a payable, by account_type.';

revoke execute on function line_contact_facts(uuid) from public, anon;
grant execute on function line_contact_facts(uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 6. suggest_line_contacts
-- ---------------------------------------------------------------------------

create or replace function suggest_line_contacts(
  p_company_id uuid,
  p_line_ids   uuid[] default null
)
returns table (
  line_id      uuid,
  contact_id   uuid,
  name         text,
  score        numeric,
  method       text,
  because      text,
  alternatives integer
)
language sql
stable
security invoker
as $$
  with lines as (
    select l.id
    from entry_lines l
    join entries e  on e.id = l.entry_id and e.company_id = l.company_id
    join accounts a on a.id = l.account_id and a.company_id = l.company_id
    where l.company_id = p_company_id
      and (p_line_ids is null or l.id = any(p_line_ids))
      and e.state = 'posted'
      and l.contact_id is null
      and a.account_type in ('asset_receivable', 'liability_payable')
      and l.matched_amount = 0
      and l.matching_number is null
      and abs(l.balance) > 0
  ),
  -- The strongest piece of evidence for each contact of each line: a contact
  -- named by a document and by its name is one candidate, said once, with the
  -- better reason.
  best as (
    select distinct on (f.line_id, s.contact_id)
           f.line_id, s.contact_id, c.name, s.score, s.method, s.because, s.alternatives
    from lines ln
    cross join lateral line_contact_facts(ln.id) f
    cross join lateral contact_candidates(
      f.company_id, 'the line', f.name, f.content, f.content,
      null, f.amount, f.currency_code, f.document_types) s
    join contacts c on c.id = s.contact_id
    order by f.line_id, s.contact_id, s.score desc, s.method
  )
  select b.line_id, b.contact_id, b.name, b.score, b.method, b.because, b.alternatives
  from best b
  order by b.line_id, b.score desc, b.method, b.name;
$$;

comment on function suggest_line_contacts(uuid, uuid[]) is
  'Who each open line on a receivable or payable account that names nobody could be — every such line of the company, or those of p_line_ids — with the candidates contact_candidates() finds, one row per line and contact, best first: a motif, the number of a document of the line''s side, the words of a name. It writes nothing and decides nothing; set_line_contact() names the line. Lines it cannot read, or of another company, give no row.';

revoke execute on function suggest_line_contacts(uuid, uuid[]) from public, anon;
grant execute on function suggest_line_contacts(uuid, uuid[]) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 7. The guard of a posted line — `20261007113412`, and one exemption
-- ---------------------------------------------------------------------------

create or replace function entry_lines_guard_posted()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $function$
declare
  -- What the matching writes, and nothing else. `balance` is generated from
  -- two columns that are frozen, and is not yet computed when a `before`
  -- trigger reads the new row.
  c_still_moves constant text[] := array['matching_number', 'matched_amount', 'balance', 'updated_at'];
  v_state  entry_state;
  v_number text;
  v_moved  text[];
begin
  -- A line written into a company the writer may not know of: nothing is
  -- read for it. The entry a line names is looked for in the line's own
  -- company.
  if tg_op <> 'DELETE' then
    perform assert_writes_into_known_company(new.company_id);
  end if;

  -- The entry the line is leaving, where it is leaving one: a line does not
  -- walk out of a posted entry into a draft.
  select e.state, e.number into v_state, v_number
    from entries e
   where e.id = coalesce(old.entry_id, new.entry_id)
     and e.company_id = coalesce(old.company_id, new.company_id);
  if found and v_state = 'draft' and tg_op = 'UPDATE' and new.entry_id is distinct from old.entry_id then
    select e.state, e.number into v_state, v_number from entries e
     where e.id = new.entry_id and e.company_id = new.company_id;
  end if;

  if not found or v_state = 'draft' then
    return coalesce(new, old);
  end if;

  if tg_op = 'DELETE' then
    if not exists (select 1 from companies c where c.id = old.company_id) then
      return old;
    end if;
    raise exception 'entry_posted: line % of entry % was posted and cannot be deleted. A posted entry is undone by a reversal that names it.',
      old.sequence, coalesce(v_number, old.entry_id::text)
      using errcode = '55006';
  end if;

  if tg_op = 'INSERT' then
    raise exception 'entry_posted: entry % was posted with the lines it has, and takes no other. A posted entry is undone by a reversal that names it.',
      coalesce(v_number, new.entry_id::text)
      using errcode = '55006';
  end if;

  select array_agg(n.key order by n.key)
    into v_moved
    from jsonb_each(to_jsonb(new)) n
    join jsonb_each(to_jsonb(old)) o on o.key = n.key
   where n.value is distinct from o.value
     and n.key <> all (c_still_moves);

  -- The one exemption (decision 0070): the contact of an open third-party
  -- line that names nobody, named once, by set_line_contact() — which raises
  -- the setting with the id of this very line — for a caller who may match.
  -- Everything else of the row is held to the rule above, and the act is
  -- written to the trail here, where it is let through.
  if v_moved = array['contact_id']
     and old.contact_id is null
     and new.contact_id is not null
     and old.matched_amount = 0
     and old.matching_number is null
     and coalesce(current_setting('ekwo.naming_line_contact', true), '') = old.id::text
     and exists (select 1 from accounts a
                  where a.id = old.account_id and a.company_id = old.company_id
                    and a.account_type in ('asset_receivable', 'liability_payable'))
  then
    if not is_installer() and not has_capability(old.company_id, 'reconcile.write') then
      raise exception 'not_allowed: naming the contact of a line in this company needs reconcile.write'
        using errcode = '42501';
    end if;
    perform audit_record(
      old.company_id, 'entry_lines', old.id,
      format('%s/%s', coalesce(v_number, old.entry_id::text), old.sequence),
      'update', 'line_contact_named',
      jsonb_build_object('contact_id', null),
      jsonb_build_object('contact_id', new.contact_id));
    return new;
  end if;

  if v_moved is not null then
    raise exception 'entry_posted: line % of entry % was posted and keeps its % (%). A posted entry is undone by a reversal that names it.',
      old.sequence, coalesce(v_number, old.entry_id::text),
      case when array_length(v_moved, 1) = 1 then 'value of' else 'values of' end,
      array_to_string(v_moved, ', ')
      using errcode = '55006';
  end if;
  return new;
end;
$function$;

comment on function entry_lines_guard_posted() is
  'Once an entry has left draft, its lines are the lines that were posted: no insert, no delete, and no column changed but the two the matching writes, matching_number and matched_amount. Refuses entry_posted, by name, to everybody. One exemption (decision 0070): contact_id, from null to a contact, on an unmatched line of a receivable or payable account, under the setting ekwo.naming_line_contact holding that line''s id — raised by set_line_contact() — for a caller holding reconcile.write; it is written to the trail as line_contact_named.';

revoke execute on function entry_lines_guard_posted() from public, anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 8. set_line_contact
-- ---------------------------------------------------------------------------

create or replace function set_line_contact(p_line_id uuid, p_contact_id uuid)
returns entry_lines
language plpgsql
volatile
security invoker
as $$
declare
  v_line  entry_lines;
  v_state entry_state;
  v_type  account_type;
  v_facts record;
begin
  -- Row level security answers this select: a line of another company is a
  -- line that does not exist.
  select * into v_line from entry_lines l where l.id = p_line_id;
  if not found then
    raise exception 'unknown_line: no ledger line %', p_line_id
      using errcode = 'no_data_found';
  end if;

  if not is_installer() and not has_capability(v_line.company_id, 'reconcile.write') then
    raise exception 'not_allowed: naming the contact of a line in this company needs reconcile.write'
      using errcode = '42501';
  end if;

  select e.state into v_state
    from entries e where e.id = v_line.entry_id and e.company_id = v_line.company_id;
  if v_state is distinct from 'posted' then
    raise exception 'line_not_posted: line % belongs to an entry that is %. A draft takes its contact like any other column, and is posted with it.',
      p_line_id, coalesce(v_state::text, 'unknown')
      using errcode = '55006';
  end if;

  if v_line.contact_id is not null then
    raise exception 'line_has_contact: line % already names a contact, and keeps it. A posted counterparty is corrected by reversing the entry.',
      p_line_id
      using errcode = '55006';
  end if;

  if v_line.matched_amount > 0 or v_line.matching_number is not null then
    raise exception 'line_matched: line % is matched, and keeps the counterparty it was matched as. Undo the matching first, with unreconcile().',
      p_line_id
      using errcode = '55006';
  end if;

  select a.account_type into v_type
    from accounts a where a.id = v_line.account_id and a.company_id = v_line.company_id;
  if v_type is null or v_type not in ('asset_receivable', 'liability_payable') then
    raise exception 'line_not_third_party: line % is on an account of type %, and only a receivable or a payable line is named this way.',
      p_line_id, coalesce(v_type::text, 'unknown')
      using errcode = '55006';
  end if;

  if not exists (select 1 from contacts c
                  where c.id = p_contact_id and c.company_id = v_line.company_id) then
    raise exception 'unknown_contact: no contact % in the company of line %', p_contact_id, p_line_id
      using errcode = 'no_data_found';
  end if;

  select * into v_facts from line_contact_facts(p_line_id);
  perform learn_contact_patterns(
    v_facts.company_id, p_contact_id, 'the line',
    v_facts.name, v_facts.content, v_facts.content,
    null, v_facts.amount, v_facts.currency_code, v_facts.document_types);

  -- The one update the guard of a posted line lets through, for this line.
  perform set_config('ekwo.naming_line_contact', p_line_id::text, true);
  update entry_lines l
     set contact_id = p_contact_id
   where l.id = p_line_id
  returning * into v_line;
  perform set_config('ekwo.naming_line_contact', '', true);

  -- Row level security writes a line for entries.write, and reads it for
  -- entries.read: a member who may match but not write the ledger reaches
  -- here and changes nothing, which is said rather than returned as success.
  if not found then
    raise exception 'not_allowed: naming the contact of a line in this company needs entries.write'
      using errcode = '42501';
  end if;

  return v_line;
end;
$$;

comment on function set_line_contact(uuid, uuid) is
  'Names the contact of an open line on a receivable or payable account that names nobody — once, from null to a contact of the same company — and learns from it through learn_contact_patterns(), as confirm_contact() does for a statement line. Needs reconcile.write. Refuses unknown_line, line_not_posted, line_has_contact, line_matched, line_not_third_party and unknown_contact by name. The guard of a posted line lets this one column through for this function alone and writes line_contact_named to the trail (decision 0070).';

revoke execute on function set_line_contact(uuid, uuid) from public, anon;
grant execute on function set_line_contact(uuid, uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 9. open_items — `20260917190000`, and the third-party lines alone
--
-- A new argument with a default is a new function to Postgres, beside the old
-- one, and a call with three arguments would then match both. So the old one
-- goes, and the new one answers every call written for it the same way.
-- ---------------------------------------------------------------------------

drop function open_items(uuid, uuid, date);

create function open_items(
  p_company_id       uuid,
  p_contact_id       uuid    default null,
  p_as_of            date    default null,
  p_third_party_only boolean default false
)
returns table (
  line_id         uuid,
  contact_id      uuid,
  account_id      uuid,
  side            text,
  amount_open     numeric,
  entry_date      date,
  date_maturity   date,
  document_id     uuid,
  document_number text,
  reference       text
)
language sql
stable
security invoker
as $$
  select l.id,
         l.contact_id,
         l.account_id,
         case when l.debit > 0 then 'debit' else 'credit' end,
         abs(l.balance) - l.matched_amount,
         e.entry_date,
         l.date_maturity,
         d.id,
         d.number,
         coalesce(d.payment_reference, d.number, e.reference)
  from entry_lines l
  join entries e   on e.id = l.entry_id
  join accounts a  on a.id = l.account_id
  left join documents d on d.entry_id = e.id
  where l.company_id = p_company_id
    and e.state = 'posted'
    and a.reconcilable
    and abs(l.balance) - l.matched_amount > 0
    and (p_contact_id is null or l.contact_id = p_contact_id)
    and (p_as_of is null or e.entry_date <= p_as_of)
    and (not coalesce(p_third_party_only, false)
         or a.account_type in ('asset_receivable', 'liability_payable'));
$$;

comment on function open_items(uuid, uuid, date, boolean) is
  'Lines with something still open on a reconcilable account, with the document behind each and the references it carries. Where there is no document — the debt of a declaration, an entry keyed by hand — the entry''s own reference answers. p_third_party_only keeps the receivable and payable lines alone, by account_type; left out, every reconcilable account answers, the bank''s included. Read by the matching, and by anybody asking what is still owed.';

revoke execute on function open_items(uuid, uuid, date, boolean) from public, anon;
grant execute on function open_items(uuid, uuid, date, boolean) to authenticated, service_role;
