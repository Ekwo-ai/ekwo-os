-- Ekwo OS — a late payment mention is the company's choice.
--
-- A pack's `late_payment` mention is the sentence that reminds a customer of
-- the interest and the recovery costs the law gives a seller paid late. Until
-- now `document_legal_mentions` printed it on every sale invoice and every
-- sale credit note of the country, with no way to leave it out. Between two
-- businesses the law applies whether or not the invoice says so: the sentence
-- recalls a right, it does not create one. So it is the seller's to print or
-- not, and it only means something where that right exists (decision 0084).
--
-- **One column on the company,** `invoice_late_payment_mention`, true by
-- default: every company that exists today keeps the sentence where the
-- condition below still finds it, and one that would rather not print it says
-- false. Generic for every pack that declares a `late_payment` mention; a pack
-- that declares none is not touched. Who may write it is who may write the
-- company: `companies_update`, `company.write`. No grant changes.
--
-- **The condition narrows to where the right is.** A sale invoice, never a
-- credit note: a credit note gives money back, nobody is paid late on it. And
-- a buyer recorded as a business, `contacts.is_company`: the rules on late
-- payment in commercial transactions are between undertakings, and a
-- consumer's are other rules a pack would carry as another mention. A sale
-- invoice that names no contact yet prints nothing, because nothing says who
-- the buyer is.
--
-- The view is read when a document is rendered, as the colour and the
-- typeface of the company are: turning the mention off shows on the next PDF.

alter table companies
  add column if not exists invoice_late_payment_mention boolean not null default true;

comment on column companies.invoice_late_payment_mention is
  'Whether this company''s sale invoices to a business print the late payment mention of its country pack (legal_mention_templates.applies_when = late_payment). True by default; never on a credit note, nor on an invoice to a consumer (contacts.is_company false), whatever it says.';

create or replace view document_legal_mentions
  with (security_invoker = true) as
  with document_taxes as (
    select d.id             as document_id,
           d.company_id,
           c.fiscal_country as country,
           d.document_date,
           d.doc_type,
           d.language,
           coalesce(
             array_agg(distinct t.treatment::text) filter (where t.treatment is not null),
             array[]::text[]
           )                                 as treatments,
           coalesce(bool_or(t.cash_basis), false) as on_cash_basis,
           d.doc_type = 'sale_invoice'
             and c.invoice_late_payment_mention
             and coalesce(k.is_company, false) as late_payment_applies
      from documents d
      join companies c           on c.id = d.company_id
      left join contacts k       on k.id = d.contact_id
      left join document_lines l on l.document_id = d.id
      left join taxes t          on t.id = l.tax_id
     group by d.id, d.company_id, c.fiscal_country, d.document_date, d.doc_type, d.language,
              c.invoice_late_payment_mention, k.is_company
  )
  select dt.document_id,
         dt.company_id,
         m.country,
         m.code,
         m.applies_when,
         dt.language,
         label_for(m.text, m.text_i18n,
                   preferred_languages(dt.language, dt.company_id)) as text,
         m.text_i18n,
         m.sequence,
         m.legal_reference
    from document_taxes dt
    join legal_mention_templates m
      on m.country = dt.country
     and m.valid_from <= dt.document_date
     and (m.valid_to is null or m.valid_to >= dt.document_date)
   where case m.applies_when
           when 'always'       then true
           when 'cash_basis'   then dt.on_cash_basis
           when 'late_payment' then dt.late_payment_applies
           else coalesce(dt.treatments && legal_mention_treatments(m.applies_when), false)
         end;

comment on view document_legal_mentions is
  'The legal mentions that apply to a document, each in the language the document was written in: its country, the validity of the mention on its date, and the treatments of the taxes its lines carry. A reverse-charge mention comes out for a domestic reverse charge, for a service received from a supplier who is not established here, and for the middle supply of a triangular arrangement — three articles behind one sentence, which is that the customer owes the tax. A late_payment mention comes out on a sale invoice to a business (contacts.is_company) of a company whose invoice_late_payment_mention is true, never on a credit note. A small_business mention never comes out, because no column records the regime.';

-- What every migration of this directory ends with: a function never comes
-- out of one with the built-in default, which Supabase would publish as an
-- anonymous RPC endpoint.
revoke execute on all functions in schema public from public;
