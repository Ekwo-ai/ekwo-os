-- Ekwo OS — what an invoice says is in the three views it is read through.
--
-- `packages/formats/README.md` tells a brick to read `document_header`,
-- `document_line_items` and `document_tax_summary` and nothing else. The first
-- brick that wrote a sendable invoice from them had to go behind them four
-- times: for the tax point, for the delivery address, for the buyer's
-- electronic address, and for the reason a tax charges nothing. Each was in
-- the schema and none was in a view. A contract that needs a join to the
-- tables under it is not the contract.
--
-- **The header gains what `documents`, `contacts` and now `companies` already
-- know.** BT-7, the four columns of BG-15 this schema has, and the two
-- electronic addresses. Nothing is invented: the delivery address has no
-- second line and no region because `documents` has neither, and a delivery
-- to a *named party* (BT-70) or a *location identifier* (BT-71) has no column
-- anywhere. They are absent rather than approximated.
--
-- **The breakdown says why a group charges nothing, in a code and in a
-- sentence.** BT-121 is `taxes.exemption_code`, which the lines view already
-- published and the breakdown did not — although it is the breakdown the
-- standard puts it on.
--
-- BT-120, the reason in words, is the decision of this file. The tax has a
-- `legal_reference`, and it is the obvious candidate and the wrong one: it is
-- the pack's *argument* — which article, why this code and not another, what
-- the pack chose not to do — written for whoever reviews the pack. Some are a
-- citation of six words and some are a paragraph that discusses this
-- repository. None was written to be read by a customer. The sentence a
-- country wants on an invoice that charges no tax exists already, per country,
-- translated, dated: `legal_mention_templates`. "Reverse charge: the customer
-- is to account for the VAT" is what BT-120 is for, and it is printed at the
-- foot of the same invoice by `document_legal_mentions`.
--
-- So `exemption_reason` is the mention of the tax's treatment, in the language
-- of the document, valid on its date — and null where the pack has no
-- sentence for that treatment, which includes every tax that charges
-- something. `legal_reference` is published beside it under its own name for
-- a reader who wants the citation, and is not called a reason.
--
-- **One place says which treatments a condition covers.** The view that
-- prints the mentions decided it in a `case`; a second copy here would drift
-- the first time a treatment is added. `legal_mention_treatments()` holds it
-- and both views read it. `document_legal_mentions` is otherwise
-- `20260915191200` to the letter: same columns, same order.
--
-- What is still missing, and is a gap of the vocabulary rather than of a view:
-- `applies_when` has no condition for a supply that is outside the scope of
-- the tax, so a category-O group has no sentence and, where the pack gives it
-- no code either, breaks BR-O-10.
--
-- Columns are appended, which is all `create or replace view` allows and what
-- keeps the grants, the comment and `security_invoker` of the object replaced.

-- ---------------------------------------------------------------------------
-- 1. The treatments behind a condition
-- ---------------------------------------------------------------------------

create or replace function legal_mention_treatments(p_applies_when text)
returns text[]
language sql
immutable
set search_path = public, pg_temp
as $$
  select case p_applies_when
           when 'reverse_charge'    then array['domestic_reverse_charge',
                                               'foreign_services_received',
                                               'intracom_triangular']
           when 'intra_eu_goods'    then array['intracom_goods', 'intracom_acquisition_goods']
           when 'intra_eu_services' then array['intracom_services', 'intracom_acquisition_services']
           when 'export'            then array['export']
           when 'exempt'            then array['exempt']
         end;
$$;

comment on function legal_mention_treatments(text) is
  'The tax treatments a condition of legal_mention_templates.applies_when covers, or null for a condition that is not about a treatment (always, late_payment, cash_basis, small_business). The one place that says so: document_legal_mentions reads it to print the sentence, document_tax_summary to give a VAT group its reason.';

revoke execute on function legal_mention_treatments(text) from public, anon;
grant execute on function legal_mention_treatments(text) to authenticated, service_role;

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
           coalesce(bool_or(t.cash_basis), false) as on_cash_basis
      from documents d
      join companies c           on c.id = d.company_id
      left join document_lines l on l.document_id = d.id
      left join taxes t          on t.id = l.tax_id
     group by d.id, d.company_id, c.fiscal_country, d.document_date, d.doc_type, d.language
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
           when 'late_payment' then dt.doc_type in ('sale_invoice', 'sale_credit_note')
           else coalesce(dt.treatments && legal_mention_treatments(m.applies_when), false)
         end;

grant select on table document_legal_mentions to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 2. The breakdown, with its reason
--
-- `20260918141107` and three columns. `d.id` and `t.id` are primary keys and
-- both are grouped on, so the columns of a document and of a tax may be read
-- without being aggregated. A reader that does not select the reason does not
-- pay for it: the planner drops an unread scalar subquery from a view, and
-- `documents_refresh_totals()` reads two sums.
-- ---------------------------------------------------------------------------

create or replace view document_tax_summary
  with (security_invoker = true) as
  select l.document_id,
         l.company_id,
         d.doc_type,
         l.tax_id,
         t.code    as tax_code,
         t.name    as tax_name,
         l.vat_category,
         l.vat_rate::numeric(12, 4) as tax_rate,
         sum(l.amount_untaxed) as base_amount,
         -- Gross tax: what the VAT return reports.
         round_amount(
           case when bool_and(l.unit_price_includes_tax)
                then sum(l.amount_incl_tax)
                     - sum(l.amount_incl_tax) / (1 + coalesce(l.vat_rate, 0) / 100)
                else sum(l.amount_untaxed) * coalesce(l.vat_rate, 0) / 100
           end,
           rounding_of(l.company_id, d.currency_code)) as tax_amount,
         -- Charged tax: what the other party actually pays. Zero when the tax
         -- postings net out, which is exactly what self-assessment means.
         round_amount(
           case when bool_and(l.unit_price_includes_tax)
                then sum(l.amount_incl_tax)
                     - sum(l.amount_incl_tax) / (1 + coalesce(l.vat_rate, 0) / 100)
                else sum(l.amount_untaxed) * coalesce(l.vat_rate, 0) / 100
           end
           * coalesce((
               select sum(tp.factor_percent)
                 from tax_postings tp
                where tp.tax_id = t.id
                  and tp.posting_type in ('tax', 'tax_on_base')
                  and tp.document_kind = case
                        when d.doc_type in ('sale_credit_note', 'purchase_credit_note')
                          then 'credit_note'::tax_document_kind
                        else 'invoice'::tax_document_kind
                      end
             ), 100) / 100,
           rounding_of(l.company_id, d.currency_code)) as tax_charged,
         t.exemption_code,                                          -- BT-121
         -- BT-120: the sentence the country puts on an invoice for the
         -- treatment of this tax, in the language of the document. Several
         -- sentences for one treatment are several sentences, in their order.
         (select string_agg(
                   label_for(m.text, m.text_i18n, preferred_languages(d.language, d.company_id)),
                   ' ' order by m.sequence, m.code)
            from legal_mention_templates m
            join companies c on c.id = d.company_id
           where m.country = c.fiscal_country
             and m.valid_from <= d.document_date
             and (m.valid_to is null or m.valid_to >= d.document_date)
             and t.treatment::text = any (legal_mention_treatments(m.applies_when))
         )                             as exemption_reason,
         t.legal_reference
    from document_lines l
    join documents d on d.id = l.document_id
    left join taxes t on t.id = l.tax_id
   where l.line_type = 'product'
   group by l.document_id, l.company_id, d.id, l.tax_id, t.id, l.vat_category, l.vat_rate;

comment on view document_tax_summary is
  'VAT breakdown of a document, one row per tax, rounded once on the group (EN 16931 BR-CO-14) — on the group''s base, or on the gross it was quoted at where the price includes the tax. The category and the rate are the ones the lines carry: the tax of today for a draft, the tax as it stood for a document that was posted. Where the tax charges nothing it says why: exemption_code is BT-121 as the pack codes it, exemption_reason is BT-120 — the sentence the country puts on an invoice for that treatment, in the language of the document, null where the pack has none. legal_reference is the article the tax rests on, written for whoever reviews the pack and not for a customer.';

grant select on table document_tax_summary to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 3. The header, with what it left in the tables
-- ---------------------------------------------------------------------------

create or replace view document_header
  with (security_invoker = true) as
  select d.id                             as document_id,
         d.company_id,
         d.doc_type,
         d.state,
         d.payment_state,
         d.number,
         d.supplier_reference,
         d.document_date,
         d.accounting_date,
         d.due_date,
         d.delivery_date,
         d.currency_code,
         d.amount_untaxed,
         d.amount_tax,
         d.amount_total,
         d.amount_paid,
         d.amount_residual,
         d.payment_terms,
         d.payment_means_code,
         d.payment_reference,
         d.buyer_reference,
         d.order_reference,
         d.contract_reference,
         d.project_reference,
         d.note,
         coalesce(d.payee_iban, seller_bank.iban) as payee_iban,
         seller_bank.bic                          as payee_bic,

         -- The seller: this company.
         coalesce(c.trade_name, c.name)   as seller_name,
         c.legal_name                     as seller_legal_name,
         c.legal_form                     as seller_legal_form,
         c.vat_number                     as seller_vat_number,
         c.registration_number            as seller_registration_number,
         c.address_line1                  as seller_address_line1,
         c.address_line2                  as seller_address_line2,
         c.postal_code                    as seller_postal_code,
         c.city                           as seller_city,
         c.country                        as seller_country,
         c.region                         as seller_region,
         c.email                          as seller_email,
         c.phone                          as seller_phone,
         c.website                        as seller_website,
         c.logo_url                       as seller_logo_url,
         c.share_capital                  as seller_share_capital,
         c.share_capital_currency         as seller_share_capital_currency,
         c.activity_code                  as seller_activity_code,
         c.activity_scheme                as seller_activity_scheme,
         c.document_template,

         -- The buyer: the contact the document is written against.
         ct.id                            as buyer_id,
         ct.name                          as buyer_name,
         ct.vat_number                    as buyer_vat_number,
         ct.registration_number           as buyer_registration_number,
         ct.address_line1                 as buyer_address_line1,
         ct.address_line2                 as buyer_address_line2,
         ct.postal_code                   as buyer_postal_code,
         ct.city                          as buyer_city,
         ct.country                       as buyer_country,
         ct.region                        as buyer_region,
         ct.email                         as buyer_email,

         -- What the country of the document requires. Its country is the
         -- company's fiscal_country — the country whose VAT rules apply — and
         -- not its address, which is the same distinction
         -- document_legal_mentions makes.
         c.fiscal_country                 as country,
         cd.number_format,
         cd.numbering_gapless,
         cd.legal_payment_days,
         cd.late_payment_reference,
         cd.tax_point_rule,
         cd.einvoice_profile,
         cd.einvoice_mandatory_from,
         cd.party_scheme,
         cd.vat_scheme,

         -- What the document is written in. Not the reader's preference and
         -- not the customer's of today: the document's own, as of the day it
         -- was issued.
         d.language,

         -- The day the tax fell due, where somebody stated one (BT-7), and
         -- where the goods went (BG-15), as far as `documents` records it.
         d.tax_point_date,
         d.delivery_address_line1,
         d.delivery_postal_code,
         d.delivery_city,
         d.delivery_country,

         -- Where the network delivers: BT-34 for the seller, BT-49 for the
         -- buyer. A scheme and a value each, both or neither.
         c.peppol_scheme                  as seller_peppol_scheme,
         c.peppol_identifier              as seller_peppol_identifier,
         ct.peppol_scheme                 as buyer_peppol_scheme,
         ct.peppol_identifier             as buyer_peppol_identifier
    from documents d
    join companies c                on c.id = d.company_id
    join contacts ct                on ct.id = d.contact_id
    left join bank_accounts seller_bank on seller_bank.id = c.default_bank_account_id
    left join country_defaults cd   on cd.country = c.fiscal_country;

comment on view document_header is
  'One document with everything printed above its lines: the seller, the buyer, the amounts, where it is paid, what its country requires, the language it is written in, the tax point and the delivery where they were stated, and the electronic address of both parties. The lines are document_line_items and the sentences are document_legal_mentions.';

grant select on table document_header to authenticated, service_role;
