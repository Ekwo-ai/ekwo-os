-- Ekwo OS — a tax lands by its code, not on a line.
--
-- A document line carries its base and names its tax (`document_lines.tax_id`);
-- when the document is posted, the tax is written on the account that
-- `tax_postings` points to (decision 0019). Nothing else is meant to reach
-- that account from a document. A line put there by hand — the VAT of a
-- purchase keyed as a second line at 0 %, or a history brought in by an
-- import that took the VAT line of the former ledger for an expense — gives
-- a document whose tax is zero while its ledger is right: the return reads
-- nothing from it, and a reader who opens the document sees a tax that is not
-- there.
--
-- So a line on an account that a tax of the company lands on is refused, with
-- the taxes that land there named so the caller puts the tax code on the base
-- line instead. One copy is let through: the credit note that
-- `cancel_document()` writes from a document posted before this guard copies
-- its lines as they were, and a line the cancelled document carries on that
-- account is carried by its credit note too — the only way left to undo it.
-- Rows already written are left as they are; the trigger reads what is written
-- from now on.

create or replace function document_lines_guard_tax_account()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_codes    text;
  v_reversed uuid;
begin
  if new.account_id is null then
    return new;
  end if;

  select string_agg(distinct t.code, ', ' order by t.code) into v_codes
    from tax_postings p
    join taxes t on t.id = p.tax_id
   where p.company_id = new.company_id
     and p.posting_type = 'tax'
     and p.account_id = new.account_id;

  if v_codes is null then
    return new;
  end if;

  -- The credit note of a document that already carries such a line copies it.
  select d.reversed_document_id into v_reversed
    from documents d
   where d.id = new.document_id;

  if v_reversed is not null and exists (
       select 1 from document_lines l
        where l.document_id = v_reversed
          and l.account_id = new.account_id)
  then
    return new;
  end if;

  raise exception 'tax_account_on_a_line: account % is where the tax % lands when a document is posted; a line carries its base and names its tax, and the posting writes the tax there',
    (select code from accounts where id = new.account_id), v_codes
    using errcode = 'check_violation',
          hint = format('put the line on an expense or revenue account and set its tax_id to the tax (%s)', v_codes);
end;
$$;

comment on function document_lines_guard_tax_account() is
  'Refuses a document line on an account that a tax of the company lands on (tax_postings, posting_type = tax): the tax of a line is its tax_id, and the posting writes it there. Lets the credit note of a cancelled document copy such a line, so a document posted before the guard can still be undone.';

revoke execute on function document_lines_guard_tax_account() from public, anon, authenticated, service_role;

create trigger document_lines_guard_tax_account
  before insert or update of account_id on document_lines
  for each row execute function document_lines_guard_tax_account();

comment on table document_lines is
  'Lines of a document. A product line carries its base, its account and its tax (tax_id); the tax itself is written by the posting on the account the tax points to, and a line on such an account is refused (trigger document_lines_guard_tax_account).';
