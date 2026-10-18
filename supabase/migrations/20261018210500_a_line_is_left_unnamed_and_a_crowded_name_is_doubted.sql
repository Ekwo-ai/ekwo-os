-- Ekwo OS — a line may be left unnamed, and a name among several is a doubt
-- (decision 0072).
--
-- Two answers to what `suggest_line_contacts()` (decision 0070) showed on
-- real books.
--
-- **Left unnamed, on purpose.** Some open lines on a receivable or payable
-- account have no contact worth creating — a cash difference, a one-off
-- refund to somebody who will never be a customer. Every pass of the screen
-- proposed them again. `leave_line_unnamed(line, reason)` records that a
-- person decided so, with the reason, in `lines_left_unnamed`, and
-- `suggest_line_contacts()` no longer proposes the line. Nothing of the line
-- moves: it is still an open item, `open_items()` still lists it, it may still
-- be matched, and `set_line_contact()` may still name it — the record is then
-- moot, since only a line that names nobody is suggested. The undo,
-- `undo_leave_line_unnamed(line)`, removes the record. Both need
-- `reconcile.write`, which is what naming a line asks.
--
-- **A name among several is not a recognition.** "Remb Pedro
-- Microsoft/Cleverbridge" on a payable credit is a debt to Pedro, who paid a
-- software licence for the company: the text carries three names, and each of
-- them scored as if it were the only one — 0.900 for Microsoft, more than for
-- Pedro. When the words of a line reach more than one contact by name, the
-- name evidence of each is capped at 0.600 and its sentence says how many
-- contacts the text reached; `alternatives` already counted them. A contact
-- whose whole name is the label (0.950) is not capped: the label names it and
-- nothing else. The document number (0.980), the account (1) and a learned
-- motif are untouched, so a document quoted in the text stays first. The cap
-- is in `contact_candidates()`, the one scoring path, so a statement line
-- carrying several names is answered the same way.

-- ---------------------------------------------------------------------------
-- 1. lines_left_unnamed
-- ---------------------------------------------------------------------------

create table lines_left_unnamed (
  line_id    uuid primary key references entry_lines(id) on delete cascade,
  company_id uuid not null references companies(id) on delete cascade,
  reason     text not null,
  created_by uuid default acting_user(),
  created_at timestamptz not null default now(),
  constraint lines_left_unnamed_reason_said
    check (length(btrim(reason)) between 1 and 500)
);

comment on table lines_left_unnamed is
  'Open lines on a receivable or payable account that a person decided to leave without a contact, with the reason: suggest_line_contacts() no longer proposes them. Written by leave_line_unnamed(), removed by undo_leave_line_unnamed(). The line itself does not move and stays an open item (decision 0072).';
comment on column lines_left_unnamed.reason is
  'Why the line names nobody, in the words of the person who decided it.';
comment on column lines_left_unnamed.created_by is
  'Who decided it: the signed-in user, or the person who issued the machine key presented (acting_user()).';

create index lines_left_unnamed_company_idx on lines_left_unnamed (company_id);

alter table lines_left_unnamed enable row level security;

create policy lines_left_unnamed_select on lines_left_unnamed
  for select using (company_id = any ((select companies_with_capability('entries.read'))::uuid[]));
create policy lines_left_unnamed_insert on lines_left_unnamed
  for insert with check (company_id = any ((select companies_with_capability('reconcile.write'))::uuid[]));
create policy lines_left_unnamed_delete on lines_left_unnamed
  for delete using (company_id = any ((select companies_with_capability('reconcile.write'))::uuid[]));

comment on policy lines_left_unnamed_select on lines_left_unnamed is
  'Read with the ledger: entries.read.';
comment on policy lines_left_unnamed_insert on lines_left_unnamed is
  'reconcile.write, which is what naming a line asks.';
comment on policy lines_left_unnamed_delete on lines_left_unnamed is
  'reconcile.write, which is what naming a line asks.';

grant select, insert, delete on table lines_left_unnamed to authenticated, service_role;

create trigger lines_left_unnamed_audit
  after insert or delete on lines_left_unnamed
  for each row execute function audit_changes('{"company":"company_id","key":["line_id"],"action_insert":"line_left_unnamed","action_delete":"line_left_unnamed_undone"}');

-- The line names a row of its own company only (decision 0065).
do $$
begin
  perform scope_references_to_company('public');
end;
$$;

-- A company leaves with what its people decided about its lines.
insert into company_archive_registry (table_name, disposition, load_order, via_column, via_table, reason) values
  ('lines_left_unnamed', 'exported', 57, null, null, null)
on conflict (table_schema, table_name) do nothing;

-- ---------------------------------------------------------------------------
-- 2. leave_line_unnamed and its undo
-- ---------------------------------------------------------------------------

create or replace function leave_line_unnamed(p_line_id uuid, p_reason text)
returns lines_left_unnamed
language plpgsql
volatile
security invoker
as $$
declare
  v_line  entry_lines;
  v_state entry_state;
  v_type  account_type;
  v_row   lines_left_unnamed;
begin
  -- Row level security answers this select: a line of another company is a
  -- line that does not exist.
  select * into v_line from entry_lines l where l.id = p_line_id;
  if not found then
    raise exception 'unknown_line: no ledger line %', p_line_id
      using errcode = 'no_data_found';
  end if;

  if not is_installer() and not has_capability(v_line.company_id, 'reconcile.write') then
    raise exception 'not_allowed: leaving a line unnamed in this company needs reconcile.write'
      using errcode = '42501';
  end if;

  if p_reason is null or length(btrim(p_reason)) = 0 then
    raise exception 'reason_required: say why the line names nobody; the reason is what the next person reads'
      using errcode = '22023';
  end if;
  if length(btrim(p_reason)) > 500 then
    raise exception 'reason_too_long: a reason is at most 500 characters'
      using errcode = '22023';
  end if;

  select e.state into v_state
    from entries e where e.id = v_line.entry_id and e.company_id = v_line.company_id;
  if v_state is distinct from 'posted' then
    raise exception 'line_not_posted: line % belongs to an entry that is %. A draft takes its contact like any other column.',
      p_line_id, coalesce(v_state::text, 'unknown')
      using errcode = '55006';
  end if;

  if v_line.contact_id is not null then
    raise exception 'line_has_contact: line % already names a contact', p_line_id
      using errcode = '55006';
  end if;

  select a.account_type into v_type
    from accounts a where a.id = v_line.account_id and a.company_id = v_line.company_id;
  if v_type is null or v_type not in ('asset_receivable', 'liability_payable') then
    raise exception 'line_not_third_party: line % is on an account of type %, and only a receivable or a payable line is suggested a contact.',
      p_line_id, coalesce(v_type::text, 'unknown')
      using errcode = '55006';
  end if;

  if exists (select 1 from lines_left_unnamed u where u.line_id = p_line_id) then
    raise exception 'line_left_unnamed: line % is already left unnamed; undo_leave_line_unnamed() takes that back', p_line_id
      using errcode = '55006';
  end if;

  insert into lines_left_unnamed (line_id, company_id, reason)
  values (p_line_id, v_line.company_id, btrim(p_reason))
  returning * into v_row;
  return v_row;
end;
$$;

comment on function leave_line_unnamed(uuid, text) is
  'Records that a person decided an open line on a receivable or payable account names nobody, with the reason: suggest_line_contacts() no longer proposes it. The line does not move and stays an open item. Needs reconcile.write. Refuses unknown_line, not_allowed, reason_required, reason_too_long, line_not_posted, line_has_contact, line_not_third_party, line_left_unnamed by name. undo_leave_line_unnamed() takes it back (decision 0072).';

revoke execute on function leave_line_unnamed(uuid, text) from public, anon;
grant execute on function leave_line_unnamed(uuid, text) to authenticated, service_role;

create or replace function undo_leave_line_unnamed(p_line_id uuid)
returns lines_left_unnamed
language plpgsql
volatile
security invoker
as $$
declare
  v_line entry_lines;
  v_row  lines_left_unnamed;
begin
  select * into v_line from entry_lines l where l.id = p_line_id;
  if not found then
    raise exception 'unknown_line: no ledger line %', p_line_id
      using errcode = 'no_data_found';
  end if;

  if not is_installer() and not has_capability(v_line.company_id, 'reconcile.write') then
    raise exception 'not_allowed: leaving a line unnamed in this company needs reconcile.write'
      using errcode = '42501';
  end if;

  delete from lines_left_unnamed u where u.line_id = p_line_id
  returning * into v_row;
  if not found then
    raise exception 'line_not_left_unnamed: line % was not left unnamed', p_line_id
      using errcode = 'no_data_found';
  end if;
  return v_row;
end;
$$;

comment on function undo_leave_line_unnamed(uuid) is
  'Takes back leave_line_unnamed(): the line is proposed a contact again. Returns the record it removed. Needs reconcile.write. Refuses unknown_line, not_allowed and line_not_left_unnamed by name.';

revoke execute on function undo_leave_line_unnamed(uuid) from public, anon;
grant execute on function undo_leave_line_unnamed(uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 3. suggest_line_contacts — `20261018180416`, without the lines left unnamed
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
      -- A person decided this one names nobody (decision 0072).
      and not exists (select 1 from lines_left_unnamed u where u.line_id = l.id)
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
  'Who each open line on a receivable or payable account that names nobody could be — every such line of the company, or those of p_line_ids — with the candidates contact_candidates() finds, one row per line and contact, best first: a motif, the number of a document of the line''s side, the words of a name (capped at 0.600 when they reach several contacts). A line left unnamed by leave_line_unnamed() is not proposed. It writes nothing and decides nothing; set_line_contact() names the line. Lines it cannot read, or of another company, give no row.';

-- ---------------------------------------------------------------------------
-- 4. contact_candidates — `20261018180416`, a name among several capped
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
  -- A text whose words reach several contacts names none of them for sure
  -- (decision 0072): each is capped at 0.600, below what a single name earns,
  -- and says how many the text reached. A label that is a contact's whole
  -- name is that contact, and keeps its 0.950.
  by_name_among as (
    select n.id,
           case when count(*) over () > 1 and n.score < 0.950 then least(n.score, 0.600) else n.score end as score,
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
