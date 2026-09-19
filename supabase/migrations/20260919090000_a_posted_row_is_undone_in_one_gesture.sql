-- Ekwo OS — what is posted is undone in one gesture.
--
-- Since `20260918161204` and `20260918161538` nothing posted moves, for
-- anybody, and both guards say how a mistake is undone instead: an entry "by a
-- reversal that names it", a document "by a credit note that names it". The
-- sentence was true and nothing did it. A reversal was eight statements the
-- caller had to get right — a draft in the same journal, every line copied
-- with its sides swapped, `reversed_entry_id`, `post_entry()`, then a matching
-- per reconcilable line — and a credit note was a draft typed again line by
-- line, named, posted, matched, and then an invoice that still said `posted`,
-- because no path of the schema could say anything else. A person does that
-- once and gets one of the eight wrong; a model does it every time it is asked
-- to "cancel that invoice", and is told by the guard to do it.
--
-- Two functions, each the whole gesture and nothing more:
--
--   * `reverse_entry(entry, date)` writes the mirror of a posted entry in its
--     journal — every line, sides swapped, with its tax, its box and its
--     analytic split — names the original in `reversed_entry_id`, posts it
--     through `post_entry()`, and matches the two on every reconcilable line.
--   * `cancel_document(document, date)` writes the credit note of a posted
--     invoice — the same lines, taxes, accounts, customer, currency and rate —
--     names the invoice in `reversed_document_id`, posts it through
--     `post_document()`, matches the two entries, and marks the invoice
--     `cancelled`.
--
-- **Nothing is posted a second way.** Both functions insert a draft and call
-- the one function that posts it, so the number is drawn from the counter,
-- the period is asked the question `post_entry()` asks, the capability is the
-- one the trigger on the transition asks for, and the audit trail records the
-- act the way it records every act: `entry_reversed` by
-- `audit_entry_posting()`, `document_posted` for the credit note and
-- `document_cancelled` for the invoice by `audit_state_change()`, and a
-- `payment_reconciled` per matching. No line of the audit is written here.
--
-- **The date is never chosen on the caller's behalf.** Left out, it is the
-- date of what is undone — the reversal then lands in the same period, which
-- is what cancelling a mistake means — *if that period is still open*. If it
-- is not, the function refuses by name (`reversal_date_needed`) and says why,
-- rather than picking "today" or the first open day: which period a
-- correction falls in is a declaration somebody files, and that is theirs to
-- decide. A date before the original is refused too; nothing is undone before
-- it happened.
--
-- **What is refused, and where it is undone instead.** A reversal that
-- undoes an entry owned by something else would leave that something saying
-- the opposite of the ledger, so the owner is named:
--
--   * an entry of a document — `cancel_document()`;
--   * a closing or appropriation entry — `reopen_fiscal_year()`; an opening
--     entry is how a set of books begins and is corrected by an entry of the
--     year, not reversed;
--   * the entry of a payment, of a bank transaction, of a module, of the
--     settlement of a declaration, and the exchange difference or the tax
--     transfer a matching wrote — each is undone with what wrote it;
--   * an entry that is itself a reversal, or that a posted reversal already
--     names;
--   * an entry or a document that is matched, in part or in full: the
--     matching says a payment settled it, and undoing the entry under it would
--     leave the payment settling nothing. Unmatch first — by hand, because
--     which matching goes is a decision about money that came in.
--
-- **The matching of the mirror is what makes the gesture one.** A reversal
-- that stays open is two open items that cancel on paper and show on every
-- aged balance. `match_reversal()` pairs each reconcilable line of the
-- original with the line of the mirror on the same account and the other side
-- and calls `reconcile()` — which letters them, books nothing in the same
-- rate, and moves a cash-basis tax the way a payment would, both ways. It is
-- a helper of the two and nothing else, and it is callable because they run
-- as their caller. Since the matching is part of the gesture, both functions
-- ask for `reconcile.write` before writing anything; and `match_reversal()`
-- refuses a caller who cannot read the chart, where "reconcilable" is written
-- — such a caller would find no pair and leave both open without a word.
--
-- **A credit note is a document, not a mirror.** Its lines are the invoice's
-- lines — product, quantity, price, discount, tax, account, text — and its
-- entry is written by `post_document()` from them, under the credit-note
-- postings of each tax. So it is the same entry reversed only as long as the
-- same lines give the same figures, and that is checked before anything is
-- posted: a credit note whose totals are not the invoice's is refused
-- (`credit_note_differs`) and nothing is written. The exchange rate is the
-- invoice's, so the two ledgers are equal to the cent and the matching
-- realises no exchange difference. What is *not* copied is every date: the
-- credit note is dated on its own day, falls due that day, and its tax point
-- is worked out from that day by the country's rule — an invoice's delivery
-- date or tax point would put the correction back into the period of the
-- invoice, which may have been declared since.
--
-- **The one way out of `posted` for a document.** `documents_guard_posted()`
-- refused every change of state out of `posted`, because nothing that says
-- `cancelled` had reversed anything. Now something has. The guard lets
-- exactly one transition through, `posted` → `cancelled`, and judges it on
-- facts as it judges the way in: a posted credit note of the matching type
-- names the document, carries its total in its currency, and the third-party
-- lines of the document are matched in full, against that credit note's entry
-- and nothing else. The caller holds `documents.post`. Nothing else moves in
-- the same statement but `payment_state`, which follows. Nothing else is
-- loosened: `posted` to `draft` is refused as before, and so is every column
-- outside the closed list.
--
-- **`reversed` is written at last.** The enum has carried it since the first
-- schema and nothing ever derived it. A document that is cancelled after it
-- was posted, and whose matching says it is settled, is `reversed` and not
-- `paid`: nobody paid it. `documents_refresh_payment_state()` derives it, and
-- now fires on a change of state as well. Unmatching the pair afterwards is
-- not refused, and the invoice then reads `not_paid` under `cancelled`, which
-- is what the matching says.
--
-- Deliberately not here: a country that allows a posted document to go back
-- to draft. That is a question for the pack, and it waits for a decision.

-- ---------------------------------------------------------------------------
-- 1. Matching a mirror against what it mirrors
-- ---------------------------------------------------------------------------

create or replace function match_reversal(p_entry_id uuid, p_reversal_id uuid)
returns integer
language plpgsql
as $$
declare
  v_line    uuid;
  v_mirror  uuid;
  v_matched integer := 0;
begin
  if not exists (
    select 1
      from entries r
      join entries o on o.id = p_entry_id
      left join documents rd on rd.entry_id = r.id
      left join documents od on od.entry_id = o.id
     where r.id = p_reversal_id
       and r.state = 'posted' and o.state = 'posted'
       and (r.reversed_entry_id = o.id
            or (rd.reversed_document_id is not null and rd.reversed_document_id = od.id))
  ) then
    raise exception 'not_a_reversal: entry % does not name entry % as what it undoes, or one of the two is not posted',
      p_reversal_id, p_entry_id;
  end if;

  -- Which lines are reconcilable is read in the chart, under the caller's
  -- policies. A caller who cannot see the account of a line would find no pair
  -- and leave both open without a word, so that is refused instead.
  if exists (
    select 1 from entry_lines l
     where l.entry_id in (p_entry_id, p_reversal_id)
       and not exists (select 1 from accounts a where a.id = l.account_id)
  ) then
    raise exception 'not_allowed: matching entry % with its reversal reads which of its accounts are reconcilable, which needs settings.read',
      p_entry_id
      using errcode = '42501';
  end if;

  -- One pair at a time, read again after every matching: `reconcile()` writes
  -- what is left open on both lines, and the next pair is what is still open.
  loop
    select o.id, m.id
      into v_line, v_mirror
      from entry_lines o
      join accounts a on a.id = o.account_id and a.reconcilable
      join entry_lines m
        on m.entry_id = p_reversal_id
       and m.account_id = o.account_id
       and (m.debit > 0) <> (o.debit > 0)
       and abs(m.debit - m.credit) > m.matched_amount
     where o.entry_id = p_entry_id
       and abs(o.debit - o.credit) > o.matched_amount
     order by o.sequence, (m.contact_id is not distinct from o.contact_id) desc, m.sequence
     limit 1;
    exit when not found;

    perform reconcile(v_line, v_mirror);
    v_matched := v_matched + 1;
  end loop;

  return v_matched;
end;
$$;

comment on function match_reversal(uuid, uuid) is
  'Matches every reconcilable line of a posted entry against the line of its posted reversal — or of the credit note of its document — on the same account and the other side, through reconcile(). Returns how many matchings it made. Written for reverse_entry() and cancel_document().';

-- ---------------------------------------------------------------------------
-- 2. reverse_entry
-- ---------------------------------------------------------------------------

create or replace function reverse_entry(p_entry_id uuid, p_date date default null)
returns entries
language plpgsql
as $$
declare
  v_entry    entries%rowtype;
  v_reversal entries%rowtype;
  v_date     date;
  v_owner    text;
begin
  select * into v_entry from entries where id = p_entry_id for update;
  if not found then
    raise exception 'unknown_entry: entry % does not exist', p_entry_id;
  end if;

  if v_entry.state <> 'posted' then
    raise exception 'entry_not_posted: entry % is % — a draft is changed or deleted, not reversed',
      coalesce(v_entry.number, v_entry.id::text), v_entry.state;
  end if;

  if v_entry.reversed_entry_id is not null then
    raise exception 'entry_is_a_reversal: entry % undoes another entry. To put the first back, post it again as a new entry; a reversal is not reversed.',
      v_entry.number;
  end if;

  select r.number into v_owner
    from entries r
   where r.reversed_entry_id = v_entry.id and r.state = 'posted'
   limit 1;
  if found then
    raise exception 'entry_already_reversed: entry % is already undone by %',
      v_entry.number, v_owner;
  end if;

  select d.doc_type || ' ' || coalesce(d.number, d.id::text) into v_owner
    from documents d
   where d.entry_id = v_entry.id or d.id = v_entry.document_id
   limit 1;
  if found then
    raise exception 'entry_of_a_document: entry % was written by %, and is undone with it: cancel_document() issues the credit note that names it.',
      v_entry.number, v_owner;
  end if;

  if v_entry.kind in ('closing', 'appropriation') then
    raise exception 'entry_of_a_year_end: entry % is the % entry of a close, and is undone by reopen_fiscal_year(), which reverses what the close wrote and opens the year again.',
      v_entry.number, v_entry.kind;
  end if;
  if v_entry.kind <> 'normal' then
    raise exception 'entry_of_a_year_end: entry % is the % entry of a set of books. It is corrected by an ordinary entry of the year, not reversed.',
      v_entry.number, v_entry.kind;
  end if;

  v_owner := coalesce(
    (select 'payment ' || coalesce(p.reference, p.id::text) || ', which is undone with it'
       from payments p where p.entry_id = v_entry.id limit 1),
    (select 'a bank transaction of ' || t.transaction_date::text || ', which is undone with it'
       from bank_transactions t where t.entry_id = v_entry.id limit 1),
    (select 'the settlement of a declaration, which reopen_filing() takes back'
       from tax_filings f where f.settlement_entry_id = v_entry.id limit 1),
    (select 'a matching, and unreconcile() takes it back'
       from reconciliations r
      where r.fx_entry_id = v_entry.id or r.tax_transfer_entry_id = v_entry.id limit 1),
    case when v_entry.module_code is not null
         then 'the module ' || v_entry.module_code || ', which undoes what it wrote' end
  );
  if v_owner is not null then
    raise exception 'entry_belongs_elsewhere: entry % was written by %.',
      v_entry.number, v_owner;
  end if;

  if exists (select 1 from entry_lines l where l.entry_id = v_entry.id and l.matched_amount > 0) then
    raise exception 'entry_matched: entry % is matched, and what matched it would be left settling nothing. Undo the matching first with unreconcile(), then reverse the entry.',
      v_entry.number;
  end if;

  -- The matching of the mirror is part of the gesture, and `reconcile()` asks
  -- for its own capability. Asked here, before anything is written, so that a
  -- caller who may post and not match is told so rather than left with a
  -- reversal that stands open. Asked of every entry, not only of one with a
  -- reconcilable line: which lines those are is read in the chart, and a
  -- caller who cannot read the chart would be told there are none.
  if not is_installer() and not has_capability(v_entry.company_id, 'reconcile.write') then
    raise exception 'not_allowed: reversing entry % matches it with its reversal, which needs reconcile.write',
      v_entry.number
      using errcode = '42501';
  end if;

  v_date := p_date;
  if v_date is null then
    begin
      perform assert_period_open(v_entry.company_id, v_entry.entry_date, true);
    exception when sqlstate '55006' then
      raise exception 'reversal_date_needed: entry % is dated %, which is no longer open (%). Pass the date of an open period to book the reversal on.',
        v_entry.number, v_entry.entry_date, sqlerrm
        using errcode = '55006';
    end;
    v_date := v_entry.entry_date;
  elsif v_date < v_entry.entry_date then
    raise exception 'reversal_before_original: entry % is dated %, and is not undone on % — before it happened.',
      v_entry.number, v_entry.entry_date, v_date;
  end if;

  insert into entries (company_id, journal_id, entry_date, reference, description,
                       state, reversed_entry_id, currency_code)
  values (v_entry.company_id, v_entry.journal_id, v_date, v_entry.reference,
          'Reversal of ' || v_entry.number, 'draft', v_entry.id, v_entry.currency_code)
  returning * into v_reversal;

  -- Every line, the other side. A box is reported with the opposite sign, and
  -- in the period of the reversal: its tax point is its own day unless that is
  -- the original's day, when the two mirror exactly.
  insert into entry_lines (entry_id, company_id, account_id, sequence, name,
                           debit, credit, currency_code, amount_currency,
                           contact_id, date_maturity, tax_id, tax_line, posting_type,
                           declaration_box, box_amount, tax_point_date)
  select v_reversal.id, l.company_id, l.account_id, l.sequence, l.name,
         l.credit, l.debit, l.currency_code, l.amount_currency,
         l.contact_id, l.date_maturity, l.tax_id, l.tax_line, l.posting_type,
         l.declaration_box, -l.box_amount,
         case when l.tax_point_date is not null then greatest(l.tax_point_date, v_date) end
    from entry_lines l
   where l.entry_id = v_entry.id
   order by l.sequence;

  insert into entry_line_analytics (company_id, entry_line_id, analytic_value_id, percentage, amount)
  select x.company_id, m.id, x.analytic_value_id, x.percentage, x.amount
    from entry_line_analytics x
    join entry_lines o on o.id = x.entry_line_id and o.entry_id = v_entry.id
    join entry_lines m on m.entry_id = v_reversal.id and m.sequence = o.sequence;

  v_reversal := post_entry(v_reversal.id);
  perform match_reversal(v_entry.id, v_reversal.id);

  return v_reversal;
end;
$$;

comment on function reverse_entry(uuid, date) is
  'Undoes a posted entry: writes its mirror in the same journal — every line with its sides swapped, its tax, its box with the opposite sign and its analytic split — names it in reversed_entry_id, posts it through post_entry() and matches the two on every reconcilable line. Dated on the original''s day while that period is open, and otherwise refused until a date is given (reversal_date_needed). Refused for an entry that is not posted, is a reversal, is already reversed, is matched, or belongs to a document (cancel_document()), a close (reopen_fiscal_year()), an opening, a payment, a bank transaction, a module, a declaration or a matching.';

-- ---------------------------------------------------------------------------
-- 3. cancel_document
-- ---------------------------------------------------------------------------

create or replace function cancel_document(p_document_id uuid, p_date date default null)
returns documents
language plpgsql
as $$
declare
  v_doc    documents%rowtype;
  v_credit documents%rowtype;
  v_date   date;
  v_type   doc_type;
  v_other  text;
begin
  select * into v_doc from documents where id = p_document_id for update;
  if not found then
    raise exception 'unknown_document: document % does not exist', p_document_id;
  end if;

  if v_doc.doc_type in ('sale_credit_note', 'purchase_credit_note') then
    raise exception 'document_is_a_credit_note: % % undoes another document. A credit note is not cancelled by another; issue the invoice again.',
      v_doc.doc_type, coalesce(v_doc.number, v_doc.id::text);
  end if;

  if v_doc.state = 'cancelled' then
    raise exception 'document_already_cancelled: % % is already cancelled',
      v_doc.doc_type, coalesce(v_doc.number, v_doc.id::text);
  end if;

  if v_doc.state <> 'posted' then
    raise exception 'document_not_posted: % % is a %, which is changed or deleted, not cancelled by a credit note',
      v_doc.doc_type, coalesce(v_doc.number, v_doc.id::text), v_doc.state;
  end if;

  v_type := case v_doc.doc_type
              when 'sale_invoice' then 'sale_credit_note'
              when 'purchase_invoice' then 'purchase_credit_note'
            end::doc_type;
  if v_type is null then
    raise exception 'document_not_accountable: a % is not cancelled by a credit note', v_doc.doc_type;
  end if;

  select coalesce(c.number, c.id::text) into v_other
    from documents c
   where c.reversed_document_id = v_doc.id and c.state = 'posted'
   limit 1;
  if found then
    raise exception 'document_already_credited: % % is already credited by %. Cancelling it would credit it twice.',
      v_doc.doc_type, v_doc.number, v_other;
  end if;

  if v_doc.amount_paid <> 0
     or exists (select 1 from entry_lines l where l.entry_id = v_doc.entry_id and l.matched_amount > 0) then
    raise exception 'document_paid: % % is settled by % already. Undo that matching first with unreconcile() — the money it records came in and stays — then cancel the document.',
      v_doc.doc_type, v_doc.number, v_doc.amount_paid;
  end if;

  -- The matching is part of the gesture; see reverse_entry().
  if not is_installer() and not has_capability(v_doc.company_id, 'reconcile.write') then
    raise exception 'not_allowed: cancelling % matches it with its credit note, which needs reconcile.write',
      v_doc.number
      using errcode = '42501';
  end if;

  v_date := p_date;
  if v_date is null then
    begin
      perform assert_period_open(v_doc.company_id, coalesce(v_doc.accounting_date, v_doc.document_date), true);
    exception when sqlstate '55006' then
      raise exception 'reversal_date_needed: % % is booked on %, which is no longer open (%). Pass the date of an open period to issue the credit note on.',
        v_doc.doc_type, v_doc.number, coalesce(v_doc.accounting_date, v_doc.document_date), sqlerrm
        using errcode = '55006';
    end;
    v_date := coalesce(v_doc.accounting_date, v_doc.document_date);
  elsif v_date < coalesce(v_doc.accounting_date, v_doc.document_date) then
    raise exception 'reversal_before_original: % % is booked on %, and is not cancelled on % — before it was issued.',
      v_doc.doc_type, v_doc.number, coalesce(v_doc.accounting_date, v_doc.document_date), v_date;
  end if;

  insert into documents (company_id, doc_type, contact_id, journal_id, document_date,
                         accounting_date, due_date, currency_code, exchange_rate,
                         supplier_reference, buyer_reference, project_reference,
                         contract_reference, order_reference,
                         delivery_address_line1, delivery_postal_code, delivery_city,
                         delivery_country, supply_territory_code, payment_means_code,
                         payee_iban, currency_code_tax, reversed_document_id, note)
  values (v_doc.company_id, v_type, v_doc.contact_id, v_doc.journal_id, v_date,
          v_date, v_date, v_doc.currency_code, v_doc.exchange_rate,
          v_doc.supplier_reference, v_doc.buyer_reference, v_doc.project_reference,
          v_doc.contract_reference, v_doc.order_reference,
          v_doc.delivery_address_line1, v_doc.delivery_postal_code, v_doc.delivery_city,
          v_doc.delivery_country, v_doc.supply_territory_code, v_doc.payment_means_code,
          v_doc.payee_iban, v_doc.currency_code_tax, v_doc.id,
          'Cancels ' || v_doc.number)
  returning * into v_credit;

  insert into document_lines (document_id, company_id, sequence, line_type, name, description,
                              quantity, unit_code, unit_price, discount_percent,
                              tax_id, account_id, product_id)
  select v_credit.id, l.company_id, l.sequence, l.line_type, l.name, l.description,
         l.quantity, l.unit_code, l.unit_price, l.discount_percent,
         l.tax_id, l.account_id, l.product_id
    from document_lines l
   where l.document_id = v_doc.id
   order by l.sequence;

  select * into v_credit from documents where id = v_credit.id;
  if (v_credit.amount_untaxed, v_credit.amount_tax, v_credit.amount_total)
     is distinct from (v_doc.amount_untaxed, v_doc.amount_tax, v_doc.amount_total) then
    raise exception 'credit_note_differs: the lines of % give % today, and it was issued at %. A tax or a rounding it was posted with has changed since; credit it by hand, line by line.',
      v_doc.number, v_credit.amount_total, v_doc.amount_total;
  end if;

  perform post_document(v_credit.id);
  select * into v_credit from documents where id = v_credit.id;
  perform match_reversal(v_doc.entry_id, v_credit.entry_id);

  update documents set state = 'cancelled' where id = v_doc.id;

  select * into v_credit from documents where id = v_credit.id;
  return v_credit;
end;
$$;

comment on function cancel_document(uuid, date) is
  'Undoes a posted invoice: writes its credit note — the same lines, taxes, accounts, contact, currency and rate — naming it in reversed_document_id, posts it through post_document(), matches the two entries and marks the invoice cancelled. Returns the credit note. Dated on the invoice''s booking day while that period is open, and otherwise refused until a date is given (reversal_date_needed). Refused for a document that is not a posted invoice, is already cancelled or credited, or is settled in part or in full (unreconcile() first).';

-- ---------------------------------------------------------------------------
-- 4. The guard of a document: one way out of `posted`
--
-- `20260918171946` as it was, with the transition to `cancelled` judged on
-- facts, the way the transition in is.
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

  if new.state is distinct from old.state then
    raise exception 'document_posted: % % is % and stays so. It is undone by a credit note that names it, which cancel_document() issues, never by changing its state to %.',
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
  'Once a document has left draft: it is not deleted, no column moves but the closed list of what happens to a document after it is issued — amount_paid (to the figure the matching gives, and no other), payment_state, sent_at, peppol_status, peppol_message_id — and its state has one way out, posted to cancelled, taken by cancel_document(): held to a posted credit note of the matching type that names it, carries its total and settles it in full, for a caller holding documents.post (document_cancelled_by_hand otherwise). Refuses document_posted, by name, to everybody. Becoming posted is held to what post_document() writes — a posted entry built for this document, booked on its day, that gave it its number — document_posted_by_hand otherwise; and nobody inserts a document that is already posted (document_born_posted).';

-- ---------------------------------------------------------------------------
-- 5. `reversed`, derived
--
-- `20260911120500` as it was, with the one state the enum always had and
-- nothing wrote; and the trigger fires on a change of state too, since that is
-- what makes a settled document `reversed`.
-- ---------------------------------------------------------------------------

create or replace function documents_refresh_payment_state()
returns trigger
language plpgsql
as $$
begin
  -- Cancelled after it was posted, and settled in full: by its credit note,
  -- which is the only thing cancel_document() lets settle it. Nobody paid it.
  if new.state = 'cancelled' and new.entry_id is not null
     and new.amount_total <> 0 and abs(new.amount_paid) >= abs(new.amount_total) then
    new.payment_state := 'reversed';
  elsif new.amount_total = 0 then
    new.payment_state := case when new.amount_paid <> 0 then 'overpaid' else 'not_paid' end;
  elsif new.amount_paid = 0 then
    new.payment_state := 'not_paid';
  elsif abs(new.amount_paid) >= abs(new.amount_total) then
    new.payment_state := case
      when abs(new.amount_paid) > abs(new.amount_total) then 'overpaid'
      else 'paid'
    end;
  else
    new.payment_state := 'partially_paid';
  end if;
  return new;
end;
$$;

comment on function documents_refresh_payment_state() is
  'Derives payment_state from amount_paid against amount_total: not_paid, partially_paid, paid, overpaid — and reversed for a document cancelled after it was posted and settled in full by its credit note. Never keyed.';

drop trigger documents_refresh_payment_state on documents;
create trigger documents_refresh_payment_state
  before insert or update of amount_total, amount_paid, state on documents
  for each row execute function documents_refresh_payment_state();

-- ---------------------------------------------------------------------------
-- Grants
--
-- The three functions run as their caller, like post_entry() and
-- post_document() they call: row level security, the capabilities on the
-- transitions and the locks are the caller's. A signed-in user and the
-- operator reach them; nobody else.
-- ---------------------------------------------------------------------------

revoke execute on all functions in schema public from public;

revoke execute on function match_reversal(uuid, uuid) from public, anon;
revoke execute on function reverse_entry(uuid, date) from public, anon;
revoke execute on function cancel_document(uuid, date) from public, anon;

grant execute on function match_reversal(uuid, uuid) to authenticated, service_role;
grant execute on function reverse_entry(uuid, date) to authenticated, service_role;
grant execute on function cancel_document(uuid, date) to authenticated, service_role;
