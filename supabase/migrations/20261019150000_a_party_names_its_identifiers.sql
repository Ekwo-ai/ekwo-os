-- Ekwo OS — a party names its identifiers, and the header publishes them.
--
-- An electronic invoice that a tax authority clears before it is issued asks
-- of both parties more than the books held: the number the tax authority
-- itself gave each of them, beside the VAT number and the number of the
-- commercial register; a registration for a tax that is not a value added
-- tax; the words of the seller's activity beside its code; the buyer's
-- telephone. Each country names these by its own register, and none of them
-- is the same identifier in two countries.
--
-- So nothing here is named after a country or a format:
--
--   * `companies.identifiers` and `contacts.identifiers` hold, by the code of
--     its scheme, every identifier of a party that has no column of its own:
--     `{"<scheme>": "<identifier>"}`. The scheme is the code the register or
--     the format names it by, and the country pack says which ones its format
--     reads (docs/packs.md, "Fiscalisation"). `vat_number` and
--     `registration_number` keep their columns and are not repeated here.
--   * `companies.activity_description` is the company's own words for its
--     activity, beside `activity_code` and `activity_scheme`: a format that
--     carries the code carries the words too.
--   * `document_header` publishes the four, and the buyer's telephone, which
--     `contacts.phone` held and the view did not.
--
-- Additive: two columns on each table, one view replaced with four columns
-- appended. The tables keep their policies and their grants, which are by
-- table; the view keeps its grant, given again below as the rule asks.

alter table companies
  add column if not exists identifiers          jsonb not null default '{}'::jsonb,
  add column if not exists activity_description text;

alter table contacts
  add column if not exists identifiers jsonb not null default '{}'::jsonb;

-- An object of non-blank texts under non-blank keys: a scheme without an
-- identifier is no identifier, and a number is written as the register
-- writes it, leading zeros included.
alter table companies
  add constraint companies_identifiers_shape check (
    jsonb_typeof(identifiers) = 'object'
    and not (identifiers ? '')
    and not jsonb_path_exists(identifiers, '$.* ? (@.type() != "string" || @ like_regex "^\\s*$")')
  );

alter table contacts
  add constraint contacts_identifiers_shape check (
    jsonb_typeof(identifiers) = 'object'
    and not (identifiers ? '')
    and not jsonb_path_exists(identifiers, '$.* ? (@.type() != "string" || @ like_regex "^\\s*$")')
  );

comment on column companies.identifiers is
  'Every identifier of the company that has no column of its own, by the code of its scheme: {"<scheme>": "<identifier>"}. The scheme is the code the register or the e-invoicing format of the country names it by — a tax identification number, a registration for a tax that is not a VAT — and the country pack says which ones its format reads. vat_number and registration_number keep their own columns and are not repeated here. Empty, not null, where there is none.';

comment on column companies.activity_description is
  'The company''s own words for its activity, beside activity_code and activity_scheme. A format that carries the code of the activity carries its description too, and the description of a register''s code is not always the words the company uses.';

comment on column contacts.identifiers is
  'Every identifier of the party that has no column of its own, by the code of its scheme: {"<scheme>": "<identifier>"}, as companies.identifiers. Empty, not null, where there is none.';

-- ---------------------------------------------------------------------------
-- The header, with the identifiers of both parties and the buyer's telephone
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
         ct.peppol_identifier             as buyer_peppol_identifier,

         -- What a format cleared by the tax authority asks of both parties:
         -- their identifiers by scheme, the words of the seller's activity,
         -- the buyer's telephone.
         c.activity_description           as seller_activity_description,
         c.identifiers                    as seller_identifiers,
         ct.identifiers                   as buyer_identifiers,
         ct.phone                         as buyer_phone
    from documents d
    join companies c                on c.id = d.company_id
    join contacts ct                on ct.id = d.contact_id
    left join bank_accounts seller_bank on seller_bank.id = c.default_bank_account_id
    left join country_defaults cd   on cd.country = c.fiscal_country;

comment on view document_header is
  'One document with everything printed above its lines: the seller, the buyer, the amounts, where it is paid, what its country requires, the language it is written in, the tax point and the delivery where they were stated, the electronic address of both parties, and the identifiers by scheme a format cleared by the tax authority asks of them (seller_identifiers, buyer_identifiers, seller_activity_description, buyer_phone). The lines are document_line_items and the sentences are document_legal_mentions.';

grant select on table document_header to authenticated, service_role;
