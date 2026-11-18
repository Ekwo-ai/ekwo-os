-- Ekwo — the `crm` module: the deal a document belongs to.
--
-- Since `20261118145000_crm_deal_documents`, a document belongs to one deal at
-- most (`crm.deal_documents`), and the answer to a quote moves that deal. The
-- link was read from the deal's side only: `crm.card_of()` lists the open
-- deals of a contact — the won deal of an accepted quote is not among them —
-- and `crm.board()` reads whole pipelines. A screen or a card that shows a
-- quote could not say which deal it belongs to.
--
-- `crm.deal_of_document()` answers that, from the document's side: the deal,
-- its stage and whether it is closed — what a card needs, and no more. Null
-- when no deal carries the document: that is an answer, not an error. A
-- document the caller cannot read in the company is refused as
-- `crm.attach_document()` refuses it, `crm_unknown_document`.
--
-- It is `security invoker` like the rest of the module: the policies of
-- `public.documents`, `crm.deal_documents`, `crm.deals` and `crm.stages`
-- decide what it reads, and `crm.require()` answers by name first.

create or replace function crm.deal_of_document(p_company_id uuid, p_document_id uuid)
returns jsonb
language plpgsql
stable
as $$
declare
  v_out jsonb;
begin
  perform crm.require(p_company_id, 'crm.read', 'reading the deal of a document');
  if not exists (select 1 from public.documents d where d.id = p_document_id and d.company_id = p_company_id) then
    raise exception 'crm_unknown_document: document % is not a document of company % you can read', p_document_id, p_company_id;
  end if;

  select jsonb_build_object(
           'id', d.id, 'title', d.title,
           'amount', d.amount::text, 'currency_code', d.currency_code,
           'stage', jsonb_build_object('id', st.id, 'name', st.name, 'outcome', st.outcome),
           'closed_at', d.closed_at, 'closed_outcome', d.closed_outcome)
    into v_out
    from crm.deal_documents l
    join crm.deals d on d.id = l.deal_id and d.company_id = l.company_id
    join crm.stages st on st.id = d.stage_id and st.pipeline_id = d.pipeline_id
   where l.document_id = p_document_id and l.company_id = p_company_id;
  return v_out;
end;
$$;

comment on function crm.deal_of_document(uuid, uuid) is
  'The deal a document of the company belongs to, as one JSON object: its id, title, amount as a decimal string and currency, its stage (id, name, outcome), closed_at and closed_outcome — open, won or lost alike. Null when no deal carries the document. A document the caller cannot read in the company is refused, crm_unknown_document. Needs crm.read.';

-- ---------------------------------------------------------------------------
-- Privileges, by name
-- ---------------------------------------------------------------------------

revoke execute on function crm.deal_of_document(uuid, uuid) from public, anon;

grant execute on function crm.deal_of_document(uuid, uuid) to authenticated, service_role;
