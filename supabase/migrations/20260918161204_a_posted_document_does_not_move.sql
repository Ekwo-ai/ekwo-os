-- Ekwo OS — what produced an entry stops moving when the entry exists.
--
-- A document is posted once: `post_document()` reads its lines, builds the
-- entry, and refuses to do it twice. From then on the ledger holds the figures
-- of that day — and the document did not. Nothing guarded it. Established
-- under row level security, as a member holding `documents.write` and nothing
-- more, on a posted invoice in an open period:
--
--   * every column of `document_lines` could be rewritten — quantity, price,
--     discount, tax, account, name — a line could be added and a line could be
--     deleted, and the totals of the document followed: an invoice posted at
--     150 read 750, 1 149 or 50 a statement later, against a ledger still at
--     150;
--   * every column of `documents` too: the three totals, the number, the three
--     dates, the customer, the currency and its rate, the type, the journal;
--     `entry_id` could be nulled, which unhooks the document from its entry;
--     `state` could go back to `draft`, after which `post_document()` books it
--     a second time; it could be set to `cancelled`, which reverses nothing;
--     and the row could be deleted, leaving its entry with no document;
--   * what was refused: the language (`document_language_frozen`), the
--     category and the rate of a line (`document_line_tax_frozen`, a day old),
--     and a second `post_document()`. The period locks guard `entries` and
--     `entry_lines` and say nothing of a document.
--
-- So an issued invoice was immutable by convention. This file makes it so by
-- the database, in the shape `tax_filing_boxes_are_frozen` has: a trigger that
-- asks one question — has the state left `draft`? — and refuses by name.
--
-- **The rule is a closed list of what may still move, not a list of what may
-- not.** A column added next month is frozen the day it is added, without
-- anybody remembering this file. What may move on a document that is no longer
-- a draft:
--
--   * `amount_paid`, and only to the figure the matching gives — so the guard
--     judges the value and not the path: `reconcile()`, `unreconcile()` and
--     whatever settles a document tomorrow all pass, and a figure keyed by
--     hand does not. `document_amount_paid()` is that figure, taken out of
--     `documents_refresh_amount_paid()` so that the two cannot disagree.
--     `payment_state` and `amount_residual` follow from it and are never
--     written: the first by trigger, the second by the column's own
--     definition;
--   * `sent_at`, `peppol_status`, `peppol_message_id`: what happened to the
--     document *after* it was issued, which by definition is written after;
--   * `updated_at`.
--
-- Nothing else, and in particular not `due_date` (it is BT-9 on the invoice
-- and the maturity of the receivable in the ledger), not `note` (BT-22 is
-- printed; there is no internal note on this table, and the day there is one
-- it joins the list by name), not `reversed_document_id` (a credit note names
-- what it credits while it is a draft). Attachments and share links are rows
-- of other tables and are not touched: filing a scan under an invoice, or
-- sending its link, changes nothing the customer was issued.
--
-- **The state goes one way.** `draft` to `posted` is the transition
-- `post_document()` makes, in one statement, and it passes untouched because
-- the row it updates is still a draft; the guard adds only that a document
-- does not become posted without an entry that is itself posted. `draft` to `cancelled` is a draft
-- abandoned. Out of `posted` there is no way: not back to `draft`, and not to
-- `cancelled` either — no function of this schema cancels a posted document,
-- and an `update` that says `cancelled` reverses nothing in the ledger. A
-- posted invoice is corrected by a credit note: a `sale_credit_note` or
-- `purchase_credit_note` naming it in `reversed_document_id`, posted by the
-- same `post_document()`, whose entry is the mirror of the first. That path
-- exists, is tested below, and is the only one.
--
-- **Nobody is exempt, because nobody needs to be.** Nothing in this file asks
-- who the caller is. `post_document()` passes because of *when* it writes, the
-- matching because of *what* it writes, `taxes_reach_draft_lines` and
-- `contacts_language_reaches_drafts` because they only ever touched drafts.
-- One exemption is a fact rather than a privilege: when the *company* is being
-- deleted the cascade removes its documents, and a guard that refused would
-- make a company undeletable. The company's row is already gone when the
-- cascade arrives, which is what the guard looks at.
--
-- **Nobody is born posted either.** A document inserted with a state that is
-- not `draft`, or a line inserted under one, is refused to everybody —
-- `document_born_posted` — the installer and an administrator of the instance
-- included. Holding `documents.post` is the right to call `post_document()`,
-- not to write an invoice it never saw.
--
-- One thing does bring documents that are already posted: `import_company()`,
-- loading a company from an archive. An exemption for it was considered — the
-- insert, and the insert only, open to whoever may load a company — and then
-- withdrawn, because the import does not need one: it switches the triggers of
-- the tables it fills off, by name, inside its own transaction, behind its own
-- guard, and switches them back on. That is the rule this file sets for a
-- backfill, applied by a function: the guard is stepped around in one place,
-- where a reviewer reads it, and asks nobody who they are. Two other ways were
-- looked at and dropped. Going through a draft — the order the books were
-- written in — is not faithful to the cent: a draft line takes its snapshot and
-- its amounts from the tax *as it stands*. And a criterion of fact, "the line
-- arrives in the transaction that created its document", reads `xmin` and stops
-- being true at the first savepoint.
--
-- What arrives that way is then frozen like everything else, for the
-- administrator who loaded it too.
--
-- **The guards read as the schema, not as the caller.** Both are `security
-- definer`, and the reason was found by a test rather than foreseen: a guard
-- that asks "is this document still a draft?" or "is the company still there?"
-- under the caller's row level security is answered *no row* by whoever cannot
-- read the table — a machine key cannot read `companies` — and "no row" was
-- the answer that let a delete through. What a guard decides must not depend
-- on what the person it is guarding against is allowed to see. They write
-- nothing; `auth.uid()`, the key and the installer's setting are the session's
-- and read the same either way.
--
-- A later migration that must restate posted rows — a backfill — will be
-- refused by this guard, and that is intended: it has to disable the trigger
-- by name, in its own file, where a reviewer reads it.
--
-- `document_line_tax_frozen` is folded into this: one guard on a line, not
-- two. `document_lines_snapshot_tax()` keeps writing the snapshot of a draft
-- and no longer refuses anything, since nothing reaches it on a posted line.
-- `documents_guard_language` stays as it is — it fires first, and its sentence
-- is the better one for what it refuses.
--
-- What this does not close, and it is the larger half: **a posted entry can
-- still be deleted, emptied of its lines, or set back to `draft` while its
-- period is open.** `entries_guard_period` protects a locked period and
-- nothing protects an open one. An entry produced by a document is now held
-- by it — deleting it would null `documents.entry_id`, which this guard
-- refuses — but an entry keyed by hand, or a payment's, is not.

-- ---------------------------------------------------------------------------
-- 1. What a document has been settled by, as a figure that can be asked for
-- ---------------------------------------------------------------------------

create or replace function document_amount_paid(p_document_id uuid)
returns numeric
language sql
stable
set search_path = public, pg_temp
as $$
  select coalesce((
           select sum(case
                        when l.amount_currency is null then l.matched_amount
                        else round_amount(l.matched_amount * l.amount_currency
                                          / nullif(abs(l.debit - l.credit), 0),
                                          rounding_of(d.company_id, d.currency_code))
                      end)
             from entry_lines l
             join accounts a on a.id = l.account_id
            where l.entry_id = d.entry_id
              and a.reconcilable
              and a.account_type in ('asset_receivable', 'liability_payable')
         ), 0)
    from documents d
   where d.id = p_document_id;
$$;

comment on function document_amount_paid(uuid) is
  'What a document has been settled by: the matched amounts on the third-party lines of its entry, in the document''s currency. The one definition — documents_refresh_amount_paid() writes it and documents_guard_posted() accepts no other figure.';

revoke execute on function document_amount_paid(uuid) from public, anon;
grant execute on function document_amount_paid(uuid) to authenticated, service_role;

create or replace function documents_refresh_amount_paid(p_document_id uuid)
returns void
language plpgsql
as $$
begin
  -- The statement names amount_paid so that documents_refresh_payment_state,
  -- which watches that column, fires in turn.
  update documents d
     set amount_paid = document_amount_paid(d.id)
   where d.id = p_document_id
     and d.entry_id is not null;
end;
$$;

comment on column documents.amount_paid is
  'Derived from reconciliations on the third-party lines of the document''s entry: document_amount_paid(). Once the document is posted, any other figure is refused.';

-- ---------------------------------------------------------------------------
-- 2. The document
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
  v_moved text[];
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
    raise exception 'document_posted: % % was issued and cannot be deleted. It is undone by a credit note that names it.',
      old.doc_type, coalesce(old.number, old.id::text)
      using errcode = '55006';
  end if;

  if old.state = 'draft' then
    -- The one transition that produces an entry has to have produced one.
    if new.state = 'posted'
       and not exists (select 1 from entries e where e.id = new.entry_id and e.state = 'posted') then
      raise exception 'document_posted_without_entry: % has no posted entry. A document is posted by post_document(), which builds its entry and posts it first.',
        coalesce(new.number, new.id::text)
        using errcode = '55006';
    end if;
    return new;
  end if;

  if new.state is distinct from old.state then
    raise exception 'document_posted: % % is % and stays so. It is undone by a credit note that names it, never by changing its state to %.',
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
  'Once a document has left draft: its state does not change, it is not deleted, and no column moves but the closed list of what happens to a document after it is issued — amount_paid (to the figure the matching gives, and no other), payment_state, sent_at, peppol_status, peppol_message_id. Refuses document_posted, by name, to everybody. Becoming posted requires an entry, and nobody inserts a document that is already posted (document_born_posted): one arrives that way only with a company loaded by import_company(), which switches this guard off by name for the time of the load.';

create trigger documents_guard_posted
  before insert or update or delete on documents
  for each row execute function documents_guard_posted();

-- A trigger body is invoked by its table, never called.
revoke execute on function documents_guard_posted() from public, anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 3. Its lines
--
-- Every column, an insert and a delete: a line of an issued document is the
-- line that was issued. `updated_at` is the one column a trigger of this
-- table writes on its own, and an update that changes nothing else is not a
-- change.
-- ---------------------------------------------------------------------------

create or replace function document_lines_guard_posted()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_state   doc_state;
  v_number  text;
  v_type    doc_type;
  v_moved   text[];
begin
  select d.state, d.number, d.doc_type into v_state, v_number, v_type
    from documents d
   where d.id = coalesce(new.document_id, old.document_id);

  -- No document: it is being deleted, and its lines with it. Whether *that*
  -- was allowed is the question documents_guard_posted() answered.
  if not found or v_state = 'draft' then
    -- A line does not leave a posted document for a draft either.
    if tg_op = 'UPDATE' and new.document_id is distinct from old.document_id then
      select d.state, d.number, d.doc_type into v_state, v_number, v_type
        from documents d where d.id = old.document_id;
      if found and v_state <> 'draft' then
        raise exception 'document_posted: a line of % % was issued with it and stays on it.',
          v_type, coalesce(v_number, old.document_id::text)
          using errcode = '55006';
      end if;
    end if;
    return coalesce(new, old);
  end if;

  if tg_op = 'DELETE' then
    if not exists (select 1 from companies c where c.id = old.company_id) then
      return old;
    end if;
    raise exception 'document_posted: line % of % % was issued and cannot be deleted. Credit the document and issue another.',
      old.sequence, v_type, coalesce(v_number, old.document_id::text)
      using errcode = '55006';
  end if;

  if tg_op = 'INSERT' then
    raise exception 'document_posted: % % was issued with the lines it has, and takes no other. Credit it and issue another.',
      v_type, coalesce(v_number, new.document_id::text)
      using errcode = '55006';
  end if;

  select array_agg(n.key order by n.key)
    into v_moved
    from jsonb_each(to_jsonb(new)) n
    join jsonb_each(to_jsonb(old)) o on o.key = n.key
   where n.value is distinct from o.value
     and n.key <> 'updated_at';

  if v_moved is not null then
    raise exception 'document_posted: line % of % % was issued and keeps its % (%). What produced an entry does not change after it; credit the document and issue another.',
      old.sequence, v_type, coalesce(v_number, old.document_id::text),
      case when array_length(v_moved, 1) = 1 then 'value of' else 'values of' end,
      array_to_string(v_moved, ', ')
      using errcode = '55006';
  end if;
  return new;
end;
$$;

comment on function document_lines_guard_posted() is
  'Once a document has left draft, its lines are the lines that were issued: no insert, no delete, no column changed. Refuses document_posted, by name, to everybody.';

-- Named to fire before the other `before` triggers of the table, which fire in
-- the order of their names: a posted line is refused by this guard, by name,
-- and not by whatever an older trigger trips over on the way — and a derived
-- column keyed on a posted line is judged as it was keyed, before the line's
-- own trigger writes the right figure back over it.
create trigger document_lines_00_guard_posted
  before insert or update or delete on document_lines
  for each row execute function document_lines_guard_posted();

-- ---------------------------------------------------------------------------
-- 3b. The totals of a posted document are not recomputed
--
-- They were derived from the lines for as long as the lines could move, by a
-- trigger that fired on every write of a line whatever the state. The lines of
-- a posted document no longer move, so there is nothing left for it to do
-- there — and what it did do, before this file, was restate the totals of a
-- sent invoice from whatever its lines had been changed to. It now acts on
-- drafts. `documents_refresh_totals()` itself is unchanged and still answers
-- for whoever calls it.
-- ---------------------------------------------------------------------------

create or replace function document_lines_refresh_totals()
returns trigger
language plpgsql
as $$
declare
  v_document uuid := coalesce(new.document_id, old.document_id);
begin
  if not exists (select 1 from documents d where d.id = v_document and d.state = 'draft') then
    return null;
  end if;
  -- The allocator writes its shares back through this same trigger, and what it
  -- wrote is already the answer. Only the outermost write allocates: a second
  -- pass would be work for nothing, and in a currency whose decimals the column
  -- cannot hold — `amount_untaxed` is `numeric(16, 2)`, which is a gap of its
  -- own — a share that comes back rounded would never compare equal and the
  -- two would call each other for ever.
  if pg_trigger_depth() <= 1 then
    perform documents_allocate_included_tax(v_document);
  end if;
  perform documents_refresh_totals(v_document);
  return null;
end;
$$;

comment on function document_lines_refresh_totals() is
  'After a line of a draft moves: shares out the base of every tax group quoted with its tax in it, then refreshes the three totals of the document. A document that is no longer a draft keeps the totals it was posted, or loaded, with.';

revoke execute on function document_lines_guard_posted() from public, anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 4. One guard on a line, not two
--
-- `20260918141107` as it was, less the branch that refused: nothing reaches it
-- on a posted line any more. It writes the snapshot of a draft, and of a line
-- that arrives.
-- ---------------------------------------------------------------------------

create or replace function document_lines_snapshot_tax()
returns trigger
language plpgsql
as $$
declare
  v_state doc_state;
begin
  select d.state into v_state from documents d where d.id = new.document_id;
  if tg_op = 'UPDATE' and v_state <> 'draft' then
    return new;
  end if;

  if new.line_type <> 'product' or new.tax_id is null then
    new.vat_category := null;
    new.vat_rate     := null;
    return new;
  end if;

  select t.vat_category,
         case when t.amount_type = 'percent' then t.amount end
    into new.vat_category, new.vat_rate
    from taxes t where t.id = new.tax_id;
  return new;
end;
$$;

comment on function document_lines_snapshot_tax() is
  'Writes BT-151 and BT-152 on a line from its tax for as long as the document is a draft. Once it is not, document_lines_guard_posted() refuses any change to the line, these two columns included.';
