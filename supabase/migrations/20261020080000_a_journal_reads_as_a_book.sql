-- Ekwo OS — a journal reads as a book.
--
-- An accountant opening the books looks for the journals first: the sales
-- journal, the purchase journal, the bank, the sundries — each a book of
-- entries in the order they were posted, with its totals for the period, and
-- all of them together the journal of the year. Until now the schema read
-- the ledger one account at a time (`general_ledger()`), ordered by account,
-- and the whole of the year's lines only as the French FEC (`fec_lines()`),
-- in that format's own columns. Nothing answered "what went through the
-- sales journal in March".
--
-- **`journal_book()`** is that reading: every line of every posted entry of
-- a period, one journal, several, or all of them, in the order a book is
-- read — the day, the journal, the entry number, then the lines of the entry
-- in their sequence. Each line carries its journal, its entry (number, kind,
-- reference, description, the document it came from and that document's
-- type, so a screen opens the invoice behind a number), its account, its
-- contact, its amounts and its matching number. No running balance: a
-- journal has none, the ledger of an account has (`general_ledger()`).
--
-- **`journal_totals()`** is the head of each book: one row per journal of
-- the company, with how many entries and lines went through it in the period
-- and their debit and credit — zero where nothing did, so a screen lists
-- every journal and not only the busy ones. A screen draws these figures; it
-- does not add the lines up again.
--
-- Both read posted entries only, through the same row level security as
-- every other reading of the ledger: a caller who may not read the entries
-- of a company reads nothing of it, and one short of `settings.read` is
-- refused at the journals and the accounts, as `general_ledger()` refuses.
-- Nothing is written, nothing is numbered.

create or replace function journal_book(
  p_company_id  uuid,
  p_from        date,
  p_to          date,
  p_journal_ids uuid[] default null
)
returns table (
  journal_id      uuid,
  journal_code    text,
  journal_name    text,
  entry_id        uuid,
  entry_number    text,
  entry_date      date,
  entry_kind      entry_kind,
  reference       text,
  description     text,
  document_id     uuid,
  document_type   text,
  entry_line_id   uuid,
  line_sequence   integer,
  account_id      uuid,
  account_code    text,
  account_name    text,
  line_name       text,
  contact_id      uuid,
  contact_name    text,
  debit           numeric,
  credit          numeric,
  matching_number text
)
language sql
stable
as $$
  select j.id, j.code, j.name,
         e.id, e.number, e.entry_date, e.kind, e.reference, e.description,
         e.document_id, d.doc_type::text,
         l.id, l.sequence,
         a.id, a.code, a.name,
         l.name, c.id, c.name,
         l.debit, l.credit, l.matching_number
    from entries e
    join journals j on j.id = e.journal_id
    join entry_lines l on l.entry_id = e.id and l.company_id = e.company_id
    join accounts a on a.id = l.account_id
    left join contacts c on c.id = l.contact_id
    left join documents d on d.id = e.document_id
   where e.company_id = p_company_id
     and e.state = 'posted'
     and e.entry_date between p_from and p_to
     and (p_journal_ids is null or e.journal_id = any (p_journal_ids))
   order by e.entry_date, j.code, e.number, e.id, l.sequence, l.id;
$$;

comment on function journal_book(uuid, date, date, uuid[]) is
  'The book of one journal, of several, or of all of them (p_journal_ids null): every line of every posted entry of the period, in the order a book is read — day, journal, entry number, line. Each line names its entry, the document behind it and that document''s type, its account and its contact. No running balance: that is general_ledger(), per account.';

create or replace function journal_totals(
  p_company_id uuid,
  p_from       date,
  p_to         date
)
returns table (
  journal_id   uuid,
  journal_code text,
  journal_name text,
  journal_type journal_type,
  active       boolean,
  entries      bigint,
  lines        bigint,
  debit        numeric,
  credit       numeric
)
language sql
stable
as $$
  select j.id, j.code, j.name, j.journal_type, j.active,
         count(distinct e.id),
         count(l.id),
         coalesce(sum(l.debit), 0)::numeric,
         coalesce(sum(l.credit), 0)::numeric
    from journals j
    left join entries e
      on e.journal_id = j.id
     and e.company_id = j.company_id
     and e.state = 'posted'
     and e.entry_date between p_from and p_to
    left join entry_lines l
      on l.entry_id = e.id
     and l.company_id = e.company_id
   where j.company_id = p_company_id
   group by j.id, j.code, j.name, j.journal_type, j.active
   order by j.code;
$$;

comment on function journal_totals(uuid, date, date) is
  'The head of each journal''s book: one row per journal of the company, with how many posted entries and lines went through it in the period and their debit and credit — zero where nothing did. A screen draws these figures rather than adding the lines of journal_book() up again.';

-- `create or replace` keeps the privileges a function already had, and a new
-- function comes out with the built-in default, which Supabase publishes as
-- an anonymous RPC endpoint: every migration of this directory ends with the
-- revoke, and grants what it created by name.
revoke execute on all functions in schema public from public;

revoke execute on function journal_book(uuid, date, date, uuid[]) from public, anon;
grant execute on function journal_book(uuid, date, date, uuid[]) to authenticated, service_role;
revoke execute on function journal_totals(uuid, date, date) from public, anon;
grant execute on function journal_totals(uuid, date, date) to authenticated, service_role;
