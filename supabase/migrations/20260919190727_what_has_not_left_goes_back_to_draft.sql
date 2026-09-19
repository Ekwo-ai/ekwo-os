-- Ekwo OS — what has not left goes back to draft, where the country allows it.
--
-- `20260919090000` made the credit note the one way to undo a posted invoice
-- and left one sentence open: "a country that allows a posted document to go
-- back to draft is a question for the pack, and it waits for a decision". The
-- decision (19 September): a posted document goes back to draft **when its
-- country allows it and nothing about it has left**; where the law forbids it —
-- continuous numbering, entries validated for good — the credit note stays the
-- only way.
--
-- **The country says it, as data.** `country_defaults.posted_edit_policy`, in a
-- closed vocabulary of two words, compiled from `documents.posted_edit_policy`
-- of the pack with the article behind it, like every document rule since
-- `20260915180000`:
--
--   * `reversal_only` — a posted document is undone by `cancel_document()`
--     and by nothing else;
--   * `unpost_if_untouched` — it may also go back to draft, through
--     `unpost_document()`, while nothing about it has left.
--
-- A pack that says nothing leaves the column null, and null is read as
-- `reversal_only`. That is not a fallback to another country's law, which is
-- what the core refuses everywhere else: it is the stricter of the two answers,
-- the one that was true for every country until today, and the one no text
-- can make illegal — a credit note is a correction every law accepts.
--
-- **What "nothing has left" means, fact by fact**, each refused by name and
-- each naming what to do instead — which is `cancel_document()`, except where
-- a matching has to be undone first:
--
--   * the document was never sent — `sent_at` is null — and never left on
--     Peppol: a customer who holds a number holds it for good;
--   * it is not settled, in part or in full, and nothing else names it: no
--     posted credit note, no entry beyond its own (a tax that fell due on
--     collection and was taken back, say);
--   * its period is open, asked the stricter question `post_entry()` asks —
--     the lock date, the tax lock date and a closed year — for the day it is
--     booked on and for every tax point of its lines;
--   * no declaration that has gone covers those days, whether or not somebody
--     moved the tax lock after filing it;
--   * where the country forbids a hole in the sequence, its number is the last
--     one its journal drew. Otherwise the draft would leave a hole behind, and
--     that is refused rather than done.
--
-- `unpost_refusal()` is the list, once. `unpost_document()` raises what it
-- returns, and a client that has to choose between the two ways to undo — the
-- command line and the MCP server do — asks it first, so the choice is the
-- database's and is made in one place.
--
-- **The number goes back to the counter, and the draft gives it up.** Where it
-- is the last one drawn, the counter of its journal steps back by one and the
-- next posting in that journal — this document again, most likely — draws it
-- once more. Keeping it on the draft instead cannot be made right: the counter
-- would have to stay where it is, the entry that carried the number is gone,
-- and the journal would show a hole at exactly the place the rule forbids one;
-- or the counter steps back and the next document of the journal is issued
-- under a number a draft still wears. So the draft carries no number, unless
-- it had one of its own before it was posted — a number that is not its
-- entry's, which is kept. In a country that allows a hole, a number that is not
-- the last is given back to nobody: the hole is what that country allows.
--
-- What `post_document()` derived goes back too, and only that: the booking day
-- where it is the document's own day, the tax point where it is the one the
-- country's rule gives. A value that differs was keyed, and is kept. Posting
-- again then derives both from the draft as it stands after it was corrected.
--
-- **The one narrow exception, and how it is kept narrow.** Both guards refuse
-- what this does: a posted document does not change state but to `cancelled`,
-- and a posted entry is not deleted. The exception cannot be judged on facts
-- alone, as the way to `cancelled` is: once the document is a draft and the
-- entry gone, nothing on any row says which of the two happened first or by
-- whose hand — and an entry keyed by hand that names a draft document would
-- look exactly like the one this takes away. Nor on a setting: a
-- transaction-local flag is writable by whoever calls `set_config` first,
-- which is why `20260918171946` refused that design.
--
-- So the act leaves a row. `document_unpostings` records every document put
-- back to draft — the entry that was taken away, its number, its journal and
-- its day, whether the number went back to the counter, who and when — and
-- nobody but `unpost_document()` writes it: no role has INSERT on it and no
-- policy would judge one. `unpost_document()` is `security definer` for that
-- reason alone, and asks for `documents.post` itself before it reads anything,
-- the way `catch_up_journal_sequence()` learnt to in `20260918114322`. The
-- guards let exactly two things through, and only in the transaction that
-- wrote the row: that document from `posted` to `draft`, with nothing moving
-- but the state, its entry, and the three values given back; and that entry
-- deleted, once no document points at it. Everything else stays refused as
-- before, in the words it was refused in.
--
-- The row is also the record of the act, since the entry it describes is gone:
-- its insert is audited as `document_unposted` by `audit_changes()`, beside the
-- `document_draft` that `audit_state_change()` writes for the document. No line
-- of the audit is written here.
--
-- **And the small fix of `20260919090000`.** Unmatching a cancelled invoice
-- from its credit note was not refused, and left an invoice that said
-- `cancelled` and `not_paid` at once. The matching is what makes `cancelled`
-- true; nothing takes it back. `reconciliations_guard_cancelled()` refuses it
-- by name, for anybody.

-- ---------------------------------------------------------------------------
-- 1. The country's word
-- ---------------------------------------------------------------------------

alter table country_defaults
  add column if not exists posted_edit_policy                 text,
  add column if not exists posted_edit_policy_legal_reference text,
  add column if not exists posted_edit_policy_source_key      text;

alter table country_defaults
  add constraint country_defaults_posted_edit_policy_known
    check (posted_edit_policy is null
           or posted_edit_policy in ('reversal_only', 'unpost_if_untouched'));

comment on column country_defaults.posted_edit_policy is
  'Whether this country lets a posted document go back to draft: reversal_only (a credit note, cancel_document(), and nothing else) or unpost_if_untouched (also unpost_document(), while the document was not sent, not settled, not declared, its period open and, where numbering is gapless, its number the last drawn). Null where the pack says nothing, read as reversal_only. posted_edit_policy() is the only function that reads it.';
comment on column country_defaults.posted_edit_policy_legal_reference is
  'The article behind posted_edit_policy, as the pack cites it.';
comment on column country_defaults.posted_edit_policy_source_key is
  'Key of the entry in the pack''s source register where that article is read.';

create or replace function posted_edit_policy(p_company_id uuid)
returns text
language sql
stable
as $$
  -- Null is the country saying nothing, and the stricter word answers for it.
  select coalesce(d.posted_edit_policy, 'reversal_only')
    from companies c
    left join country_defaults d on d.country = c.fiscal_country
   where c.id = p_company_id;
$$;

comment on function posted_edit_policy(uuid) is
  'What the country of a company says about a posted document: reversal_only or unpost_if_untouched. A country that says nothing gets reversal_only, the stricter of the two, which every law accepts. The only function that reads the column.';

-- ---------------------------------------------------------------------------
-- 2. The record of the act
-- ---------------------------------------------------------------------------

create table document_unpostings (
  id              uuid primary key default gen_random_uuid(),
  company_id      uuid not null references companies(id) on delete cascade,
  -- No foreign key on either: the draft may be deleted afterwards and the
  -- entry is gone by construction, and this row is what says both existed.
  document_id     uuid not null,
  doc_type        doc_type not null,
  entry_id        uuid not null,
  entry_number    text not null,
  journal_id      uuid not null,
  entry_date      date not null,
  -- True where the number was the last one its journal drew and the counter
  -- stepped back; false where it was not, in a country that allows the hole.
  number_returned boolean not null,
  unposted_by     uuid default auth.uid(),
  unposted_at     timestamptz not null default now(),
  -- The transaction that wrote the row, which is the one the guards let
  -- through. Nothing after it can use this row to move anything.
  transaction_id  bigint not null default txid_current()
);

comment on table document_unpostings is
  'Every posted document put back to draft by unpost_document(): the entry that was taken away, its number, journal and day, and whether the number went back to the counter. Written by unpost_document() and by nothing else — no role may insert — so the guards read a row here, written in the same transaction, as the one exception to "a posted document does not go back to draft" and "a posted entry is not deleted".';

create index document_unpostings_document_idx on document_unpostings (document_id);
create index document_unpostings_entry_idx on document_unpostings (entry_id);
create index document_unpostings_company_idx on document_unpostings (company_id);

alter table document_unpostings enable row level security;

create policy document_unpostings_select on document_unpostings
  for select using (company_id = any ((select companies_with_capability('documents.read'))::uuid[]));

comment on policy document_unpostings_select on document_unpostings is
  'Whoever reads the documents of a company reads which of them went back to draft. Nobody writes here but unpost_document(), so there is no other policy.';

grant select on table document_unpostings to authenticated, service_role;

create trigger document_unpostings_audit
  after insert on document_unpostings
  for each row execute function audit_changes(
    '{"company":"company_id","key":["entry_number"],"action_insert":"document_unposted"}');

-- A company leaves with the record: it is the only place an entry that was
-- taken away is still described, and its number with it.
insert into company_archive_registry (table_name, disposition, load_order, via_column, via_table, reason) values
  ('document_unpostings', 'exported', 64, null, null,
   'Which posted documents went back to draft, and the entry and number each gave up: the one trace of an entry that no longer exists.')
on conflict (table_schema, table_name) do nothing;

-- ---------------------------------------------------------------------------
-- 3. Why a document does not go back to draft
-- ---------------------------------------------------------------------------

create or replace function unpost_refusal(p_document_id uuid)
returns text
language plpgsql
stable
as $$
declare
  v_doc     documents%rowtype;
  v_entry   entries%rowtype;
  v_what    text;
  v_other   text;
  v_day     date;
  v_filing  record;
  v_format  text;
  v_gapless boolean;
  v_code    text;
  v_period  smallint;
  v_last    integer;
begin
  select * into v_doc from documents where id = p_document_id;
  if not found then
    return format('unknown_document: document %s does not exist', p_document_id);
  end if;
  v_what := v_doc.doc_type || ' ' || coalesce(v_doc.number, v_doc.id::text);

  if not is_installer() and not has_capability(v_doc.company_id, 'documents.post') then
    return 'not_allowed: putting a posted document back to draft in this company needs documents.post';
  end if;

  if v_doc.state <> 'posted' then
    return format('document_not_posted: %s is %s, and only a posted document goes back to draft', v_what, v_doc.state);
  end if;

  if v_doc.doc_type not in ('sale_invoice', 'purchase_invoice', 'sale_credit_note', 'purchase_credit_note') then
    return format('document_not_accountable: a %s books nothing, so there is no posting to take back', v_doc.doc_type);
  end if;

  if posted_edit_policy(v_doc.company_id) <> 'unpost_if_untouched' then
    return format(
      'posted_edit_reversal_only: the law of this company''s country keeps a posted document as it was posted — its pack declares reversal_only, or says nothing, which reads the same — so %s does not go back to draft. Undo it with cancel_document(), which issues the credit note that names it.',
      v_what);
  end if;

  if v_doc.sent_at is not null then
    return format('document_sent: %s was sent on %s, and a number a customer holds is kept. Undo it with cancel_document(), which issues the credit note that names it.',
      v_what, v_doc.sent_at::date);
  end if;
  if coalesce(v_doc.peppol_status, '') not in ('', 'none') or v_doc.peppol_message_id is not null then
    return format('document_sent: %s left on Peppol (%s), and a number a customer holds is kept. Undo it with cancel_document(), which issues the credit note that names it.',
      v_what, coalesce(nullif(v_doc.peppol_status, ''), v_doc.peppol_message_id));
  end if;

  select * into v_entry from entries where id = v_doc.entry_id;
  if not found then
    return format('unknown_entry: the entry of %s is not visible to you', v_what);
  end if;

  if v_doc.amount_paid <> 0
     or exists (select 1 from entry_lines l where l.entry_id = v_entry.id and l.matched_amount > 0) then
    return format('document_paid: %s is settled by %s already. Undo that matching first with unreconcile() — the money it records came in and stays.',
      v_what, v_doc.amount_paid);
  end if;

  select coalesce(c.number, c.id::text) into v_other
    from documents c
   where c.reversed_document_id = v_doc.id and c.state = 'posted'
   limit 1;
  if found then
    return format('document_already_credited: %s is credited by %s, which names it. Undo that credit note first, or leave both as they are.',
      v_what, v_other);
  end if;

  select coalesce(e.number, e.id::text) into v_other
    from entries e
   where e.document_id = v_doc.id and e.id <> v_entry.id
   limit 1;
  if found then
    return format('document_has_history: %s is named by entry %s beside its own — a tax that fell due on collection and was taken back, an exchange difference — and that stays. Undo it with cancel_document(), which issues the credit note that names it.',
      v_what, v_other);
  end if;

  -- The day it is booked on and every tax point of its lines, asked the
  -- question posting asks: the lock date, the tax lock date, a closed year.
  for v_day in
    select v_entry.entry_date
    union
    select l.tax_point_date from entry_lines l
     where l.entry_id = v_entry.id and l.tax_point_date is not null
     order by 1
  loop
    begin
      perform assert_period_open(v_doc.company_id, v_day, true);
    exception when sqlstate '55006' then
      return format('document_period_closed: %s is booked or taxed on %s, which is no longer open (%s). Undo it with cancel_document() on a date that is.',
        v_what, v_day, sqlerrm);
    end;

    select f.report_code, f.period_start, f.period_end, f.state into v_filing
      from tax_filings f
     where f.company_id = v_doc.company_id
       and f.state not in ('draft', 'ready', 'superseded')
       and v_day between f.period_start and f.period_end
     order by f.period_start
     limit 1;
    if found then
      return format('document_declared: %s falls in the declaration %s of %s to %s, which is %s. Undo it with cancel_document(), which the next declaration carries.',
        v_what, v_filing.report_code, v_filing.period_start, v_filing.period_end, v_filing.state);
    end if;
  end loop;

  -- Where the law forbids a hole, only the last number drawn goes back.
  select r.number_format, r.numbering_gapless into v_format, v_gapless
    from numbering_rules(v_doc.company_id) r;
  if v_gapless then
    select j.code into v_code from journals j where j.id = v_entry.journal_id;
    v_period := case when v_format ~ '\{(YYYY|YY)\}'
                     then extract(year from v_entry.entry_date)::smallint
                     else 0::smallint end;
    select s.last_number into v_last
      from journal_sequences s
     where s.journal_id = v_entry.journal_id and s.year = v_period;
    if v_last is null or v_entry.number is distinct from format_number(v_format, v_code, v_entry.entry_date, v_last) then
      return format('document_not_last_number: %s is not the last number journal %s drew — %s came after it — and this country forbids a hole in the sequence. Undo it with cancel_document(), which issues the credit note that names it.',
        coalesce(v_entry.number, v_entry.id::text), v_code,
        case when v_last is null then 'another'
             else format_number(v_format, v_code, v_entry.entry_date, v_last) end);
    end if;
  end if;

  return null;
end;
$$;

comment on function unpost_refusal(uuid) is
  'Why a posted document may not go back to draft, as the sentence unpost_document() would raise — null where it may. Read first by a client that chooses between unpost_document() and cancel_document(), so that the choice is made here and nowhere else. Asks, in order: documents.post, a posted invoice or credit note, a country whose posted_edit_policy is unpost_if_untouched, never sent nor on Peppol, not settled, not credited, named by no other entry, a period open for its day and every tax point, no declaration gone over them, and — where numbering is gapless — the last number of its journal.';

-- ---------------------------------------------------------------------------
-- 4. unpost_document
-- ---------------------------------------------------------------------------

create or replace function unpost_document(p_document_id uuid)
returns documents
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_doc     documents%rowtype;
  v_entry   entries%rowtype;
  v_refusal text;
  v_format  text;
  v_code    text;
  v_period  smallint;
  v_last    integer;
  v_is_last boolean;
begin
  select * into v_doc from documents where id = p_document_id for update;
  if not found then
    raise exception 'unknown_document: document % does not exist', p_document_id;
  end if;

  -- Definer: the caller is asked here, before anything is read on their behalf.
  if not is_installer() and not has_capability(v_doc.company_id, 'documents.post') then
    raise exception 'not_allowed: putting a posted document back to draft in this company needs documents.post'
      using errcode = '42501';
  end if;

  select * into v_entry from entries where id = v_doc.entry_id for update;

  -- The counter is held until the transaction ends, so that "the last number
  -- drawn" is still true when it is given back.
  if found then
    select r.number_format into v_format from numbering_rules(v_doc.company_id) r;
    select j.code into v_code from journals j where j.id = v_entry.journal_id;
    v_period := case when v_format ~ '\{(YYYY|YY)\}'
                     then extract(year from v_entry.entry_date)::smallint
                     else 0::smallint end;
    select s.last_number into v_last
      from journal_sequences s
     where s.journal_id = v_entry.journal_id and s.year = v_period
       for update;
  end if;

  v_refusal := unpost_refusal(p_document_id);
  if v_refusal is not null then
    raise exception '%', v_refusal
      using errcode = case split_part(v_refusal, ':', 1)
                        when 'not_allowed' then '42501'
                        when 'document_period_closed' then '55006'
                        when 'document_declared' then '55006'
                        else 'P0001'
                      end;
  end if;

  v_is_last := v_last is not null
               and v_entry.number = format_number(v_format, v_code, v_entry.entry_date, v_last);

  insert into document_unpostings (company_id, document_id, doc_type, entry_id, entry_number,
                                   journal_id, entry_date, number_returned)
  values (v_doc.company_id, v_doc.id, v_doc.doc_type, v_entry.id, v_entry.number,
          v_entry.journal_id, v_entry.entry_date, v_is_last);

  -- Back to what it was before post_document(): what posting derived goes,
  -- what was keyed stays.
  update documents
     set state = 'draft',
         entry_id = null,
         number = case when number is not distinct from v_entry.number then null else number end,
         accounting_date = case when accounting_date is not distinct from document_date
                                then null else accounting_date end,
         tax_point_date = case when tax_point_date is not distinct from
                                    tax_point_of(company_id, document_date, delivery_date, null)
                               then null else tax_point_date end
   where id = v_doc.id
  returning * into v_doc;

  -- Its lines and their analytic split go with it, by the foreign keys.
  delete from entries where id = v_entry.id;

  if v_is_last then
    update journal_sequences
       set last_number = last_number - 1
     where journal_id = v_entry.journal_id and year = v_period and last_number = v_last;
  end if;

  return v_doc;
end;
$$;

comment on function unpost_document(uuid) is
  'Puts a posted invoice or credit note back to draft, where its country''s posted_edit_policy is unpost_if_untouched and nothing about it has left — every condition is unpost_refusal(), raised by name otherwise, and each refusal says to cancel_document() instead or what to undo first. Records the act in document_unpostings, takes the entry away, gives the number back to the counter where it was the last drawn, and returns the draft — without the number where it was its entry''s, and without the booking day and tax point where posting had derived them. Definer, because document_unpostings is written by nobody else; asks documents.post itself.';

-- ---------------------------------------------------------------------------
-- 5. The guard of a document: the way back to draft
--
-- `20260919090000` as it was, with the second way out of `posted`.
-- ---------------------------------------------------------------------------

create or replace function documents_guard_posted()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  -- What may still move once the state has left `draft`. A closed list: a
  -- column that is not named here is frozen, including one that does not
  -- exist yet.
  c_still_moves constant text[] := array[
    'amount_paid', 'amount_residual', 'payment_state',
    'sent_at', 'peppol_status', 'peppol_message_id',
    'updated_at'
  ];
  -- And what moves when a posted document is cancelled: the state, and the
  -- settlement that follows from it. Nothing else, not even what may move on
  -- any other day. `amount_residual` is generated, and not yet computed in a
  -- `before` trigger.
  c_cancel_moves constant text[] := array['state', 'payment_state', 'amount_residual', 'updated_at'];
  -- And what moves when it goes back to draft: the state, its entry, and the
  -- three values post_document() derived, given back.
  c_unpost_moves constant text[] := array[
    'state', 'entry_id', 'number', 'accounting_date', 'tax_point_date',
    'payment_state', 'amount_residual', 'updated_at'
  ];
  v_moved  text[];
  v_entry  entries%rowtype;
  v_credit documents%rowtype;
begin
  if tg_op = 'INSERT' then
    if new.state <> 'draft' then
      raise exception 'document_born_posted: a document is written as a draft and posted by post_document(). One that is already % arrives with a company being loaded, by import_company(), and in no other way.',
        new.state
        using errcode = '55006';
    end if;
    return new;
  end if;

  if tg_op = 'DELETE' then
    if old.state = 'draft'
       or not exists (select 1 from companies c where c.id = old.company_id) then
      return old;
    end if;
    raise exception 'document_posted: % % was issued and cannot be deleted. It is undone by a credit note that names it, which cancel_document() issues.',
      old.doc_type, coalesce(old.number, old.id::text)
      using errcode = '55006';
  end if;

  if old.state = 'draft' then
    -- The one transition that produces an entry has to have produced one.
    if new.state = 'posted' then
      select e.* into v_entry from entries e where e.id = new.entry_id and e.state = 'posted';
      if not found then
        raise exception 'document_posted_without_entry: % has no posted entry. A document is posted by post_document(), which builds its entry and posts it first.',
          coalesce(new.number, new.id::text)
          using errcode = '55006';
      end if;
      -- What post_document() leaves behind, read on the two rows: the entry
      -- was built for this document and for no other, the document is booked
      -- on the day its entry is, and it is numbered as it was — or, where it
      -- had no number, as its entry.
      if v_entry.document_id is distinct from new.id
         or new.accounting_date is distinct from v_entry.entry_date
         or new.number is distinct from coalesce(old.number, v_entry.number) then
        raise exception 'document_posted_by_hand: % is not what post_document() writes — its entry % was not built for it, or is not booked on its day, or did not give it its number. A document is posted by post_document() and by nothing else.',
          coalesce(new.number, new.id::text), coalesce(v_entry.number, v_entry.id::text)
          using errcode = '55006';
      end if;
    end if;
    return new;
  end if;

  -- The way out of `posted`, and the only one: what cancel_document() leaves
  -- behind, read on the rows. A posted credit note of the matching type names
  -- this document and carries its total in its currency, and the third-party
  -- lines of this document are matched in full against that credit note's
  -- entry and nothing else. Whoever wrote the statement, those are the facts
  -- that make `cancelled` true.
  if old.state = 'posted' and new.state = 'cancelled' then
    select array_agg(n.key order by n.key)
      into v_moved
      from jsonb_each(to_jsonb(new)) n
      join jsonb_each(to_jsonb(old)) o on o.key = n.key
     where n.value is distinct from o.value
       and n.key <> all (c_cancel_moves);
    if v_moved is not null then
      raise exception 'document_posted: % % is cancelled with nothing else changed, and would change its % (%).',
        old.doc_type, coalesce(old.number, old.id::text),
        case when array_length(v_moved, 1) = 1 then 'value of' else 'values of' end,
        array_to_string(v_moved, ', ')
        using errcode = '55006';
    end if;

    if not is_installer() and not has_capability(old.company_id, 'documents.post') then
      raise exception 'not_allowed: cancelling a document in this company needs documents.post'
        using errcode = '42501';
    end if;

    select c.* into v_credit
      from documents c
     where c.reversed_document_id = old.id
       and c.state = 'posted'
       and c.doc_type = case old.doc_type
                          when 'sale_invoice' then 'sale_credit_note'
                          when 'purchase_invoice' then 'purchase_credit_note'
                        end::doc_type
       and c.currency_code = old.currency_code
       and c.amount_total = old.amount_total
     limit 1;

    if not found
       or exists (
         select 1
           from entry_lines l
           join accounts a on a.id = l.account_id
          where l.entry_id = old.entry_id
            and a.reconcilable
            and a.account_type in ('asset_receivable', 'liability_payable')
            and l.matched_amount < abs(l.debit - l.credit))
       or exists (
         select 1
           from reconciliations r
           join entry_lines l on l.id in (r.debit_line_id, r.credit_line_id)
           join entry_lines x on x.id = case when l.id = r.debit_line_id
                                             then r.credit_line_id else r.debit_line_id end
          where l.entry_id = old.entry_id
            and x.entry_id is distinct from v_credit.entry_id) then
      raise exception 'document_cancelled_by_hand: % % is cancelled by cancel_document(), which issues the credit note that names it and matches the two. A posted document becomes cancelled when that credit note exists and settles it in full, and in no other way.',
        old.doc_type, coalesce(old.number, old.id::text)
        using errcode = '55006';
    end if;
    return new;
  end if;

  -- The way back to draft: unpost_document() has recorded the act for this
  -- document and this entry, in this transaction. That row is written by
  -- nobody else, and it is only written once every condition of
  -- unpost_refusal() held. The draft gives up its entry, and its number if it
  -- was the entry's; nothing else moves but what posting had derived.
  if old.state = 'posted' and new.state = 'draft'
     and exists (
       select 1 from document_unpostings u
        where u.document_id = old.id
          and u.entry_id = old.entry_id
          and u.transaction_id = txid_current()) then
    select array_agg(n.key order by n.key)
      into v_moved
      from jsonb_each(to_jsonb(new)) n
      join jsonb_each(to_jsonb(old)) o on o.key = n.key
     where n.value is distinct from o.value
       and n.key <> all (c_unpost_moves);
    if v_moved is not null
       or new.entry_id is not null
       or (new.number is not null and new.number is distinct from old.number) then
      raise exception 'document_posted: % % goes back to draft with nothing else changed, and would change its %.',
        old.doc_type, coalesce(old.number, old.id::text),
        coalesce(array_to_string(v_moved, ', '), 'entry or number')
        using errcode = '55006';
    end if;
    return new;
  end if;

  if new.state is distinct from old.state then
    raise exception 'document_posted: % % is % and stays so. It is undone by a credit note that names it, which cancel_document() issues — or, where its country allows it and nothing about it has left, put back to draft by unpost_document() — never by changing its state to %.',
      old.doc_type, coalesce(old.number, old.id::text), old.state, new.state
      using errcode = '55006';
  end if;

  select array_agg(n.key order by n.key)
    into v_moved
    from jsonb_each(to_jsonb(new)) n
    join jsonb_each(to_jsonb(old)) o on o.key = n.key
   where n.value is distinct from o.value
     and n.key <> all (c_still_moves);

  if v_moved is not null then
    raise exception 'document_posted: % % was issued and keeps its % (%). What produced an entry does not change after it; credit it and issue another.',
      old.doc_type, coalesce(old.number, old.id::text),
      case when array_length(v_moved, 1) = 1 then 'value of' else 'values of' end,
      array_to_string(v_moved, ', ')
      using errcode = '55006';
  end if;

  if new.amount_paid is distinct from old.amount_paid
     and new.amount_paid is distinct from document_amount_paid(new.id) then
    raise exception 'document_amount_paid_is_derived: % has been settled by %, which is what its matching says. The figure is never keyed.',
      coalesce(old.number, old.id::text), document_amount_paid(new.id)
      using errcode = '55006';
  end if;

  if new.payment_state is distinct from old.payment_state
     and new.amount_paid is not distinct from old.amount_paid then
    raise exception 'document_payment_state_is_derived: the settlement of % follows from what was matched against it, and is never keyed.',
      coalesce(old.number, old.id::text)
      using errcode = '55006';
  end if;

  return new;
end;
$$;

comment on function documents_guard_posted() is
  'Once a document has left draft: it is not deleted, no column moves but the closed list of what happens to a document after it is issued — amount_paid (to the figure the matching gives, and no other), payment_state, sent_at, peppol_status, peppol_message_id — and its state has two ways out. Posted to cancelled, taken by cancel_document(): held to a posted credit note of the matching type that names it, carries its total and settles it in full, for a caller holding documents.post (document_cancelled_by_hand otherwise). Posted to draft, taken by unpost_document(): held to the row it records in document_unpostings for this document and its entry in the same transaction, with nothing moving but the state, the entry and what posting derived. Refuses document_posted, by name, to everybody else. Becoming posted is held to what post_document() writes — a posted entry built for this document, booked on its day, that gave it its number — document_posted_by_hand otherwise; and nobody inserts a document that is already posted (document_born_posted).';

-- ---------------------------------------------------------------------------
-- 6. The guard of an entry: the one posted entry that is deleted
--
-- `20260918171946` as it was, with the delete that unpost_document() records.
-- ---------------------------------------------------------------------------

create or replace function entries_guard_posted()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_moved   text[];
  v_format  text;
  v_gapless boolean;
  v_code    text;
  v_period  smallint;
  v_last    integer;
begin
  if tg_op = 'INSERT' then
    if new.state <> 'draft' then
      raise exception 'entry_born_posted: an entry is written as a draft and posted by post_entry(). One that is already % arrives with a company being loaded, by import_company(), and in no other way.',
        new.state
        using errcode = '55006';
    end if;
    return new;
  end if;

  if old.state = 'draft' then
    if tg_op = 'UPDATE' and new.state = 'posted' then
      if new.posted_at is null then
        raise exception 'entry_posted_by_hand: entry % would be posted with no instant it was posted at. An entry is posted by post_entry() and by nothing else.',
          coalesce(new.number, new.id::text)
          using errcode = '55006';
      end if;
      -- Null is what post_entry() itself writes where it finds no year — a company
      -- that has not opened one, or a caller who cannot read `fiscal_years`, which
      -- is a machine key today. A year that is *named* has to be the right one.
      if new.fiscal_year_id is not null
         and new.fiscal_year_id is distinct from fiscal_year_at(new.company_id, new.entry_date) then
        raise exception 'entry_posted_by_hand: entry % would be posted outside the financial year its date falls in. An entry is posted by post_entry() and by nothing else.',
          coalesce(new.number, new.id::text)
          using errcode = '55006';
      end if;

      if not exists (select 1 from entry_lines l where l.entry_id = new.id) then
        raise exception 'entry_empty: entry % has no lines', new.id;
      end if;

      perform assert_period_open(new.company_id, new.entry_date, true);

      select r.number_format, r.numbering_gapless into v_format, v_gapless
        from numbering_rules(new.company_id) r;
      select j.code into v_code from journals j where j.id = new.journal_id;
      v_period := case when v_format ~ '\{(YYYY|YY)\}'
                       then extract(year from new.entry_date)::smallint
                       else 0::smallint end;
      select s.last_number into v_last
        from journal_sequences s
       where s.journal_id = new.journal_id and s.year = v_period;

      if v_last is not null and new.number = format_number(v_format, v_code, new.entry_date, v_last) then
        return new;  -- drawn from the counter, a moment ago, by this transaction
      end if;

      -- A number chosen by hand: on the draft beforehand, or in this statement.
      if v_gapless and not (auth.uid() is not null and has_capability(new.company_id, 'entries.import')) then
        raise exception 'entry_posted_by_hand: % is not the number the counter of this journal delivered, and this country forbids a hole in the sequence. An entry is posted by post_entry(), which draws it; books that already have numbers are brought in by whoever holds entries.import.',
          new.number
          using errcode = '55006';
      end if;
      perform catch_up_journal_sequence(new.journal_id, new.entry_date, new.number);
    end if;
    return coalesce(new, old);
  end if;

  if tg_op = 'DELETE' then
    if not exists (select 1 from companies c where c.id = old.company_id) then
      return old;
    end if;
    -- The entry of a document unpost_document() has just put back to draft,
    -- recorded in this transaction, and which no document points at any more.
    if exists (
         select 1 from document_unpostings u
          where u.entry_id = old.id
            and u.transaction_id = txid_current())
       and not exists (select 1 from documents d where d.entry_id = old.id) then
      return old;
    end if;
    raise exception 'entry_posted: entry % is % and cannot be deleted. A posted entry is undone by a reversal that names it.',
      coalesce(old.number, old.id::text), old.state
      using errcode = '55006';
  end if;

  if new.state is distinct from old.state then
    raise exception 'entry_posted: entry % is % and stays so. A posted entry is undone by a reversal that names it, never by changing its state to %.',
      coalesce(old.number, old.id::text), old.state, new.state
      using errcode = '55006';
  end if;

  select array_agg(n.key order by n.key)
    into v_moved
    from jsonb_each(to_jsonb(new)) n
    join jsonb_each(to_jsonb(old)) o on o.key = n.key
   where n.value is distinct from o.value
     -- `is_balanced` is generated, and not yet computed in a `before` trigger.
     and n.key not in ('updated_at', 'is_balanced');

  if v_moved is not null then
    raise exception 'entry_posted: entry % was posted and keeps its % (%). A posted entry is undone by a reversal that names it.',
      coalesce(old.number, old.id::text),
      case when array_length(v_moved, 1) = 1 then 'value of' else 'values of' end,
      array_to_string(v_moved, ', ')
      using errcode = '55006';
  end if;
  return new;
end;
$$;

comment on function entries_guard_posted() is
  'Once an entry has left draft: its state does not change and no column moves (entry_posted); it is not deleted, but for the entry of a document unpost_document() has put back to draft, recorded in document_unpostings in the same transaction and pointed at by no document any more; nobody inserts one that is already posted (entry_born_posted). Becoming posted is held to what post_entry() produces, read on the row and in the counter — an instant it was posted at, no financial year but the one its date falls in, at least one line, an open period, and, where the country numbers without a hole and the caller does not hold entries.import, the number the counter of its journal has just delivered: entry_posted_by_hand otherwise.';

-- ---------------------------------------------------------------------------
-- 7. A cancelled document stays matched to what cancelled it
-- ---------------------------------------------------------------------------

create or replace function reconciliations_guard_cancelled()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_what text;
begin
  -- A company being deleted takes its matchings with it.
  if not exists (select 1 from companies c where c.id = old.company_id) then
    return old;
  end if;

  select d.doc_type || ' ' || coalesce(d.number, d.id::text) into v_what
    from entry_lines l
    join documents d on d.entry_id = l.entry_id
   where l.id in (old.debit_line_id, old.credit_line_id)
     and d.state = 'cancelled'
   limit 1;
  if found then
    raise exception 'document_cancelled_stays_matched: % is cancelled, and this matching against its credit note is what makes that true. It is not undone: a cancelled document stays cancelled. Issue the document again if it was right after all.',
      v_what
      using errcode = '55006';
  end if;
  return old;
end;
$$;

comment on function reconciliations_guard_cancelled() is
  'Refuses to undo a matching on the entry of a cancelled document: cancel_document() matched it against its credit note, and that matching is what makes cancelled true. Unmatching it would leave a document that says cancelled and not_paid at once. document_cancelled_stays_matched, for everybody.';

create trigger reconciliations_guard_cancelled
  before delete on reconciliations
  for each row execute function reconciliations_guard_cancelled();

-- ---------------------------------------------------------------------------
-- Grants
--
-- The two readers run as their caller. unpost_document() is definer and asks
-- for documents.post itself; a signed-in user and the operator reach it, and
-- nobody else. The guard is a trigger body, callable by nobody.
-- ---------------------------------------------------------------------------

revoke execute on all functions in schema public from public;

revoke execute on function posted_edit_policy(uuid) from public, anon;
revoke execute on function unpost_refusal(uuid) from public, anon;
revoke execute on function unpost_document(uuid) from public, anon;
revoke execute on function reconciliations_guard_cancelled() from public, anon, authenticated, service_role;

grant execute on function posted_edit_policy(uuid) to authenticated, service_role;
grant execute on function unpost_refusal(uuid) to authenticated, service_role;
grant execute on function unpost_document(uuid) to authenticated, service_role;
