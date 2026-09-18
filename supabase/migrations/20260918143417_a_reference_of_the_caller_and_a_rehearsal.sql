-- A reference of the caller's own, and a rehearsal of posting
--
-- Two things a caller with nothing but a shell cannot do without, and which
-- no client can do on the database's behalf.
--
-- 1. **Not doubling what it created.** An agent sends "create this invoice",
--    the connection drops before the answer arrives, and it cannot know
--    whether the invoice exists. Sending again makes two. The fix every API
--    reaches for is a key the caller chooses and repeats; the only place that
--    can hold it honestly is the row, under a unique index, because a lookup
--    in a client is a race and an index is not. `client_ref` is that key, on
--    the three things a person creates by hand: a contact, a document, a
--    payment. It means nothing to the books — it is never printed on an
--    invoice, never read by a report — and it is unique per company where it
--    is given, and absent everywhere else.
--
-- 2. **Knowing what posting would do, without doing it.** `post_document()`
--    is where every rule is: the accounts, the taxes, the territory, the tax
--    point, the locks, the number. A client that wants to show the entry
--    before it exists has two options, and one of them is to reimplement all
--    of that. `rehearse_post_document()` is the other: it *calls*
--    `post_document()`, reads what it wrote, and undoes it — a subtransaction
--    rolled back on purpose. So a rehearsal refuses exactly what posting would
--    refuse, in the same words, and shows exactly the lines posting would
--    write, because it is the same code and not a description of it.

-- ---------------------------------------------------------------------------
-- client_ref
-- ---------------------------------------------------------------------------

alter table contacts  add column if not exists client_ref text;
alter table documents add column if not exists client_ref text;
alter table payments  add column if not exists client_ref text;

alter table contacts  add constraint contacts_client_ref_not_blank
  check (client_ref is null or (client_ref = btrim(client_ref) and length(client_ref) between 1 and 200));
alter table documents add constraint documents_client_ref_not_blank
  check (client_ref is null or (client_ref = btrim(client_ref) and length(client_ref) between 1 and 200));
alter table payments  add constraint payments_client_ref_not_blank
  check (client_ref is null or (client_ref = btrim(client_ref) and length(client_ref) between 1 and 200));

create unique index if not exists contacts_client_ref_key
  on contacts (company_id, client_ref) where client_ref is not null;
create unique index if not exists documents_client_ref_key
  on documents (company_id, client_ref) where client_ref is not null;
create unique index if not exists payments_client_ref_key
  on payments (company_id, client_ref) where client_ref is not null;

comment on column contacts.client_ref is
  'A reference chosen by whoever created the row, unique per company where given. It exists so a caller that repeats a creation after a dropped connection finds the first one instead of making a second. It means nothing to the books.';
comment on column documents.client_ref is
  'A reference chosen by whoever created the document, unique per company where given: the idempotency key of a creation. Not the document number, not the supplier''s reference, and never printed.';
comment on column payments.client_ref is
  'A reference chosen by whoever recorded the payment, unique per company where given: the idempotency key of a creation. Not the bank''s reference, which is `reference`.';

-- ---------------------------------------------------------------------------
-- rehearse_post_document
-- ---------------------------------------------------------------------------

create or replace function rehearse_post_document(p_document_id uuid)
returns jsonb
language plpgsql
volatile
security invoker
as $$
declare
  v_entry  entries;
  v_result jsonb;
begin
  begin
    v_entry := post_document(p_document_id);

    select jsonb_build_object(
      'entry', jsonb_build_object(
        'number',       v_entry.number,
        'entry_date',   v_entry.entry_date::text,
        'journal_id',   v_entry.journal_id,
        'total_debit',  v_entry.total_debit::text,
        'total_credit', v_entry.total_credit::text
      ),
      'entry_lines', coalesce((
        select jsonb_agg(jsonb_build_object(
                 'sequence',     l.sequence,
                 'account_id',   l.account_id,
                 'account_code', a.code,
                 'account_name', a.name,
                 'name',         l.name,
                 'debit',        l.debit::text,
                 'credit',       l.credit::text,
                 'tax_id',       l.tax_id,
                 'contact_id',   l.contact_id
               ) order by l.sequence)
        from entry_lines l
        join accounts a on a.id = l.account_id
        where l.entry_id = v_entry.id
      ), '[]'::jsonb)
    ) into v_result;

    -- The way out of the block that undoes everything done inside it. A
    -- variable is not part of the transaction, so the answer survives.
    raise exception using errcode = 'EKW01', message = 'rehearsal';
  exception
    when sqlstate 'EKW01' then
      null;
  end;

  return v_result;
end;
$$;

comment on function rehearse_post_document(uuid) is
  'What post_document() would write, without writing it: the function is called for real inside a block that is then rolled back, so every rule, lock and refusal is the real one. The entry number shown is the one it would take now; somebody else posting first takes it instead. Amounts are text.';

revoke execute on function rehearse_post_document(uuid) from public, anon;
grant execute on function rehearse_post_document(uuid) to authenticated, service_role;
