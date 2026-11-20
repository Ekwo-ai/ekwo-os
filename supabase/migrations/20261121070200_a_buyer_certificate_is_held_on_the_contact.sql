-- A buyer's certificate is held on the contact.
--
-- A tax may say, in `tax_templates.conditions`, that it turns on a
-- certificate the buyer hands the seller: a resale certificate, an exemption
-- certificate, a declaration of intent. Until now that word documented the
-- question and nothing recorded the answer, so a sale under such a tax posted
-- whether or not the seller held anything — and the seller is the one liable
-- for the tax the day the certificate cannot be produced.
--
-- This migration gives the answer a place, and the word one reader:
--
--   1. `contact_tax_certificates`: a certificate a contact handed over — its
--      reference, the territory it is valid in, the day it starts and, where
--      it has one, the day it ends. The paper itself is an attachment, as any
--      other file.
--   2. `documents_hold_buyer_certificate`: a sale invoice a line of which
--      carries a tax conditioned on `buyer_certificate` is refused at posting
--      (`no_buyer_certificate`) unless its contact holds a certificate valid on
--      the document's date and, where the certificate names a territory, for
--      the place of supply.
--
-- The core still chooses no tax for anybody. It holds the evidence the pack
-- said the tax depends on, and refuses the tax where the evidence is missing,
-- the way it refuses a tax whose territory the document contradicts. What a
-- certificate must contain is in the article the tax cites; nothing here
-- reads a certificate's content, and no other word of `conditions` is read.
--
-- A credit note is not held to it: it reverses a sale that was, and refusing
-- the correction of a sale because a certificate expired since would keep the
-- wrong figure in the books. A purchase is not either: there the company is
-- the buyer, and the certificate is one it handed over.

-- ---------------------------------------------------------------------------
-- 1. The certificate
-- ---------------------------------------------------------------------------

create table ekwo.contact_tax_certificates (
  id             uuid primary key default gen_random_uuid(),
  company_id     uuid not null references ekwo.companies(id) on delete cascade,
  contact_id     uuid not null,
  reference      text not null,
  territory_code text references ekwo.territories(code),
  valid_from     date not null,
  valid_to       date,
  note           text,
  client_ref     text,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  foreign key (contact_id, company_id) references ekwo.contacts (id, company_id) on delete cascade,
  constraint contact_tax_certificates_reference_named check (btrim(reference) <> ''),
  constraint contact_tax_certificates_period check (valid_to is null or valid_to >= valid_from),
  constraint contact_tax_certificates_client_ref_check
    check (client_ref is null or (client_ref = btrim(client_ref) and length(client_ref) between 1 and 200))
);

comment on table ekwo.contact_tax_certificates is
  'A certificate a buyer handed the company, which a tax conditioned on buyer_certificate (tax_templates.conditions) depends on: a resale certificate, an exemption certificate, a declaration of intent. post_document() refuses a sale invoice under such a tax unless its contact holds one valid on the document''s date (no_buyer_certificate). The paper itself is an attachment; what it must contain is in the article the tax cites, and nothing here reads it.';
comment on column ekwo.contact_tax_certificates.contact_id is
  'The buyer who handed it over. A merge of contacts moves it to the contact kept, as every row that names a contact.';
comment on column ekwo.contact_tax_certificates.reference is
  'The number or reference the certificate carries, as written on it. Not unique: a buyer may hand over a renewed certificate under the same number.';
comment on column ekwo.contact_tax_certificates.territory_code is
  'The territory under whose law the certificate was given, a code of territories: a sale is covered where its place of supply lies inside it. Null for a certificate that names none, which covers every place of supply.';
comment on column ekwo.contact_tax_certificates.valid_from is
  'The first day the certificate covers: a sale dated earlier is not covered by it.';
comment on column ekwo.contact_tax_certificates.valid_to is
  'The last day it covers, where it has one — an expiry printed on it, or the day the buyer withdrew it. Null while it stands.';
comment on column ekwo.contact_tax_certificates.note is
  'Free text: what was checked, where the paper is kept.';

comment on column ekwo.contact_tax_certificates.client_ref is
  'A reference chosen by whoever recorded the row, unique per company where given, so that a caller repeating the recording after a dropped connection finds the first one instead of making a second. It means nothing to the books.';

create unique index contact_tax_certificates_client_ref_key
  on ekwo.contact_tax_certificates (company_id, client_ref) where client_ref is not null;

create index contact_tax_certificates_contact_idx
  on ekwo.contact_tax_certificates (contact_id, company_id, valid_from);
create index contact_tax_certificates_territory_idx
  on ekwo.contact_tax_certificates (territory_code);

create trigger contact_tax_certificates_set_updated_at
  before update on ekwo.contact_tax_certificates
  for each row execute function ekwo.set_updated_at();

alter table ekwo.contact_tax_certificates enable row level security;

create policy contact_tax_certificates_select on ekwo.contact_tax_certificates
  for select using (company_id = any ((select ekwo.companies_with_capability('contacts.read'))::uuid[]));
create policy contact_tax_certificates_write on ekwo.contact_tax_certificates
  for all using (company_id = any ((select ekwo.companies_with_capability('contacts.write'))::uuid[]))
  with check (company_id = any ((select ekwo.companies_with_capability('contacts.write'))::uuid[]));

comment on policy contact_tax_certificates_select on ekwo.contact_tax_certificates is
  'Whoever reads the contacts reads the certificates they handed over.';
comment on policy contact_tax_certificates_write on ekwo.contact_tax_certificates is
  'contacts.write: a certificate is something the buyer handed over, recorded on the buyer, by whoever keeps the contacts.';

grant select, insert, update, delete on table ekwo.contact_tax_certificates to authenticated, service_role;

create trigger contact_tax_certificates_audit
  after insert or update or delete on ekwo.contact_tax_certificates
  for each row execute function ekwo.audit_changes('{"company":"company_id","key":["id"]}');

-- A company leaves with the certificates its buyers handed over, after the
-- contacts they name.
insert into ekwo.company_archive_registry (table_name, disposition, load_order, via_column, via_table, reason) values
  ('contact_tax_certificates', 'exported', 41, null, null,
   'The certificates the buyers handed over, after the contacts that hold them: a sale posted under one was posted because of it.')
on conflict (table_schema, table_name) do nothing;

-- A certificate never names a merged contact, as no row does (decision 0074).
do $$
begin
  perform ekwo.refuse_merged_contacts_in('ekwo');
end;
$$;

-- ---------------------------------------------------------------------------
-- 2. Which certificate covers a sale
-- ---------------------------------------------------------------------------

create or replace function ekwo.buyer_certificate_for(p_document_id uuid)
returns ekwo.contact_tax_certificates
language sql
stable
set search_path = ekwo, pg_temp
as $$
  select c.*
    from ekwo.documents d
    join ekwo.contact_tax_certificates c
      on c.company_id = d.company_id
     and c.contact_id = d.contact_id
   where d.id = p_document_id
     and c.valid_from <= d.document_date
     and (c.valid_to is null or c.valid_to >= d.document_date)
     and (c.territory_code is null
          or ekwo.territory_within(ekwo.document_territory(d.id, 'supply'), c.territory_code))
   order by c.valid_from desc, c.created_at desc
   limit 1;
$$;

comment on function ekwo.buyer_certificate_for(uuid) is
  'The certificate of contact_tax_certificates that covers a document: handed over by its contact, valid on its document_date, and either naming no territory or one the place of supply (document_territory(..., ''supply'')) lies inside. The most recent when several do; null when none does.';

revoke execute on function ekwo.buyer_certificate_for(uuid) from public, anon;
grant execute on function ekwo.buyer_certificate_for(uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 3. A sale under such a tax is refused without one
-- ---------------------------------------------------------------------------

create or replace function ekwo.documents_hold_buyer_certificate()
returns trigger
language plpgsql
set search_path = ekwo, pg_temp
as $$
declare
  v_tax record;
begin
  if new.doc_type <> 'sale_invoice' then
    return new;
  end if;
  select t.code, l.sequence into v_tax
    from document_lines l
    join taxes t on t.id = l.tax_id
    join tax_templates tt on tt.country = t.country and tt.code = t.code
   where l.document_id = new.id
     and 'buyer_certificate' = any (tt.conditions)
   order by l.sequence
   limit 1;
  if not found then
    return new;
  end if;
  if new.contact_id is null then
    raise exception 'no_buyer_certificate: line % carries %, which applies on a certificate the buyer hands over, and this document names no buyer to hold one; name the contact',
      v_tax.sequence, v_tax.code
      using errcode = '23514';
  end if;
  if (buyer_certificate_for(new.id)).id is null then
    raise exception 'no_buyer_certificate: line % carries %, which applies on a certificate the buyer hands over, and the buyer holds none valid on % for this place of supply; record it on the contact (contact_tax_certificates, ekwo contact certificate add), or book the line under another tax',
      v_tax.sequence, v_tax.code, new.document_date
      using errcode = '23514';
  end if;
  return new;
end;
$$;

comment on function ekwo.documents_hold_buyer_certificate() is
  'Refuses to post a sale invoice a line of which carries a tax conditioned on buyer_certificate (tax_templates.conditions) when buyer_certificate_for() finds no certificate its contact handed over that covers it (no_buyer_certificate). The one word of conditions the core reads; a credit note and a purchase are not held to it.';

revoke execute on function ekwo.documents_hold_buyer_certificate() from public, anon, authenticated, service_role;

create trigger documents_hold_buyer_certificate
  before update of state on ekwo.documents
  for each row
  when (new.state = 'posted' and old.state is distinct from 'posted')
  execute function ekwo.documents_hold_buyer_certificate();

comment on column ekwo.tax_templates.conditions is
  'What this tax turns on that the ledger cannot see, from a closed vocabulary: buyer_certificate, buyer_status, transport_evidence, seller_threshold, supply_nature. It says what the question is, never how to answer it — there is no value, no operator and no expression here, and the article that sets a threshold or prescribes a certificate is in legal_reference. Written by the generated seed. buyer_certificate is read when a sale invoice is posted, against contact_tax_certificates; the other words are read by nothing in the ledger.';
