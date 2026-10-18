-- Ekwo OS — a piece goes on its document, not on the entry the document posted.
--
-- `attachments` is polymorphic and has accepted `entity_type = 'entry'` since
-- `20260911120800`. An entry that a document posted is the ledger side of that
-- document (`entries.document_id`, `documents.entry_id`, decision 0008): the
-- invoice or the receipt behind it is the document's piece. A file kept on the
-- entry as well is a second copy of the same piece in a second place, and a
-- reader who opens the document does not see it.
--
-- So an attachment on an entry that a document posted is refused, with the
-- document named so the caller can attach there instead. An entry that no
-- document posted — a journal entry keyed by hand, a year-end adjustment, an
-- opening, an imported ledger line — still takes its own piece: nothing else
-- would hold it. Rows already on such entries are left as they are; the
-- trigger reads what is written from now on.

create or replace function attachments_guard_document()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_document uuid;
begin
  if new.entity_type <> 'entry' then
    return new;
  end if;

  select coalesce(e.document_id, d.id) into v_document
    from entries e
    left join documents d on d.entry_id = e.id
   where e.id = new.entity_id
   limit 1;

  if v_document is not null then
    raise exception 'attachment_belongs_on_document: entry % was posted by document %; attach the file to the document',
      new.entity_id, v_document
      using errcode = 'check_violation',
            hint = format('insert it with entity_type = ''document'' and entity_id = %s', v_document);
  end if;

  return new;
end;
$$;

comment on function attachments_guard_document() is
  'Refuses a file on an entry that a document posted: the invoice or receipt is the piece of the document, and goes on it (entity_type = document). An entry no document posted keeps its own pieces.';

revoke execute on function attachments_guard_document() from public, anon, authenticated, service_role;

create trigger attachments_guard_document
  before insert or update of entity_type, entity_id on attachments
  for each row execute function attachments_guard_document();

comment on table attachments is
  'Files attached to any record. `entity_type` is constrained rather than free text. An invoice or a receipt goes on its document; an entry takes a file only when no document posted it (trigger attachments_guard_document).';
