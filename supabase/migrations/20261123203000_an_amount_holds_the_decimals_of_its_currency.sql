-- Ekwo OS — an amount holds the decimals of its currency.
--
-- Since `20260914120500_rounding_reads_the_currency`, every amount the engine
-- computes is rounded by one function, `round_amount()`, to the decimals of
-- its currency: two for the euro, none for the yen, three for the Kuwaiti or
-- the Tunisian dinar. The columns that hold those amounts were still
-- `numeric(16, 2)` (and a few `numeric(18, 2)`), so a third decimal the engine
-- had computed was rounded away a second time, by the column, on the way in.
-- Decision 0011 named that gap; this file closes it.
--
-- **A money column is a bare `numeric`.** No precision, no scale: the rounding
-- rule lives in `round_amount()` and nowhere else — no `numeric(20, 6)` that
-- would be a second rule, no trigger that rounds behind the writer's back.
-- Rates, percentages, quantities and unit prices keep their own types; they
-- are not amounts of a currency and nothing here touches them.
--
-- **What changes for a reader.** `numeric` prints the scale a value holds. An
-- amount the engine rounded keeps printing as before (`round(100, 2)` is
-- `100.00`); an amount written as `100` by a caller now reads back `100`, where
-- the column used to pad it to `100.00`. Every text an amount is written in
-- for a person or a format goes through `amount_text_format()` or its own
-- format's rule, never through the scale of the column.
--
-- **Removing a typmod from `numeric` rewrites nothing**: the values stay as
-- they are on disk. Postgres still refuses to change the type of a column that
-- a view, a trigger or a generated column reads, so those are dropped and
-- recreated here, with the definitions, comments and grants they had:
--
--   * the views `document_header`, `document_line_items`,
--     `document_tax_summary` and `bank_statement_continuity`;
--   * the eight triggers that name an amount in `update of` or `when`;
--   * the generated columns `entry_lines.balance`,
--     `documents.amount_residual`, `entries.is_balanced` and
--     `bank_statements.is_consistent`. A generated column cannot be retyped
--     nor have its inputs retyped, so it is dropped and added again with the
--     same expression; it is computed again from the row, and moves to the
--     end of its table.
--
-- The modules that own money columns widen them in a migration of their own.

-- ---------------------------------------------------------------------------
-- 1. What reads the columns, set aside
-- ---------------------------------------------------------------------------

drop view ekwo.document_header;
drop view ekwo.document_line_items;
drop view ekwo.document_tax_summary;
drop view ekwo.bank_statement_continuity;

drop trigger bank_transactions_refresh_balance on ekwo.bank_transactions;
drop trigger bank_statements_recompute on ekwo.bank_statements;
drop trigger companies_default_capital_currency on ekwo.companies;
drop trigger documents_refresh_payment_state on ekwo.documents;
drop trigger entry_lines_refresh_totals on ekwo.entry_lines;
drop trigger document_lines_analytics_follow on ekwo.document_lines;
drop trigger entry_lines_analytics_follow on ekwo.entry_lines;
drop trigger tax_filings_paid_by_matching on ekwo.entry_lines;

alter table ekwo.entries drop column is_balanced;
alter table ekwo.entry_lines drop column balance;
alter table ekwo.documents drop column amount_residual;
alter table ekwo.bank_statements drop column is_consistent;

-- ---------------------------------------------------------------------------
-- 2. The money columns, bare `numeric`
-- ---------------------------------------------------------------------------

alter table ekwo.entries
  alter column total_debit  type numeric,
  alter column total_credit type numeric;

alter table ekwo.entry_lines
  alter column debit           type numeric,
  alter column credit          type numeric,
  alter column amount_currency type numeric,
  alter column box_amount      type numeric,
  alter column matched_amount  type numeric;

alter table ekwo.documents
  alter column amount_untaxed type numeric,
  alter column amount_tax     type numeric,
  alter column amount_total   type numeric,
  alter column amount_paid    type numeric;

alter table ekwo.document_lines
  alter column amount_untaxed    type numeric,
  alter column amount_incl_tax   type numeric,
  alter column stated_tax_amount type numeric;

alter table ekwo.document_line_analytics alter column amount type numeric;
alter table ekwo.entry_line_analytics    alter column amount type numeric;
alter table ekwo.payments                alter column amount type numeric;
alter table ekwo.reconciliations         alter column amount type numeric;
alter table ekwo.bank_transactions       alter column amount type numeric;

alter table ekwo.bank_statements
  alter column balance_start        type numeric,
  alter column balance_end_declared type numeric,
  alter column balance_end_computed type numeric;

alter table ekwo.companies alter column share_capital type numeric;

alter table ekwo.contact_patterns
  alter column amount_min     type numeric,
  alter column amount_max     type numeric,
  alter column amount_typical type numeric;

alter table ekwo.declaration_instalments alter column amount type numeric;

alter table ekwo.turnover_tax_assessments
  alter column turnover        type numeric,
  alter column window_turnover type numeric,
  alter column tax             type numeric,
  alter column deduction       type numeric;

alter table ekwo.turnover_tax_brackets
  alter column up_to     type numeric,
  alter column deduction type numeric;

alter table ekwo.vat_scheme_ceilings    alter column amount       type numeric;
alter table ekwo.vat_scheme_instalments alter column minimum_base type numeric;

-- ---------------------------------------------------------------------------
-- 3. The generated columns, with the expressions they had
-- ---------------------------------------------------------------------------

alter table ekwo.entries
  add column is_balanced boolean generated always as (total_debit = total_credit) stored;
alter table ekwo.entry_lines
  add column balance numeric generated always as (debit - credit) stored;
alter table ekwo.documents
  add column amount_residual numeric generated always as (amount_total - amount_paid) stored;
alter table ekwo.bank_statements
  add column is_consistent boolean generated always as (balance_end_declared = balance_end_computed) stored;

-- ---------------------------------------------------------------------------
-- 4. The triggers, as they were
-- ---------------------------------------------------------------------------

create trigger bank_transactions_refresh_balance
  after insert or delete or update of amount, statement_id on ekwo.bank_transactions
  for each row execute function ekwo.bank_statements_refresh_balance();

create trigger bank_statements_recompute
  before insert or update of balance_start on ekwo.bank_statements
  for each row execute function ekwo.bank_statements_recompute();

create trigger companies_default_capital_currency
  before insert or update of share_capital, share_capital_currency, currency_code on ekwo.companies
  for each row execute function ekwo.companies_default_capital_currency();

create trigger documents_refresh_payment_state
  before insert or update of amount_total, amount_paid, state on ekwo.documents
  for each row execute function ekwo.documents_refresh_payment_state();

create trigger entry_lines_refresh_totals
  after insert or delete or update of debit, credit, entry_id on ekwo.entry_lines
  for each row execute function ekwo.entries_refresh_totals();

create trigger document_lines_analytics_follow
  after update on ekwo.document_lines
  for each row
  when (old.amount_untaxed is distinct from new.amount_untaxed
        or old.account_id is distinct from new.account_id)
  execute function ekwo.document_lines_analytics_follow();

create trigger entry_lines_analytics_follow
  after update on ekwo.entry_lines
  for each row
  when (old.debit is distinct from new.debit
        or old.credit is distinct from new.credit
        or old.account_id is distinct from new.account_id)
  execute function ekwo.entry_lines_analytics_follow();

create trigger tax_filings_paid_by_matching
  after update of matched_amount on ekwo.entry_lines
  for each row
  when (old.matched_amount is distinct from new.matched_amount)
  execute function ekwo.tax_filings_paid_by_matching();

-- ---------------------------------------------------------------------------
-- 5. The views, as they were
--
-- The same definitions, read back from the catalogue of the schema before
-- this file; only the type of the amount columns they pass through changes.
-- ---------------------------------------------------------------------------

create view ekwo.document_header
  with (security_invoker = true) as
 SELECT d.id AS document_id,
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
    COALESCE(d.payee_iban, seller_bank.iban) AS payee_iban,
    seller_bank.bic AS payee_bic,
    COALESCE(c.trade_name, c.name) AS seller_name,
    c.legal_name AS seller_legal_name,
    c.legal_form AS seller_legal_form,
    c.vat_number AS seller_vat_number,
    c.registration_number AS seller_registration_number,
    c.address_line1 AS seller_address_line1,
    c.address_line2 AS seller_address_line2,
    c.postal_code AS seller_postal_code,
    c.city AS seller_city,
    c.country AS seller_country,
    c.region AS seller_region,
    c.email AS seller_email,
    c.phone AS seller_phone,
    c.website AS seller_website,
    c.logo_url AS seller_logo_url,
    c.share_capital AS seller_share_capital,
    c.share_capital_currency AS seller_share_capital_currency,
    c.activity_code AS seller_activity_code,
    c.activity_scheme AS seller_activity_scheme,
    c.document_template,
    ct.id AS buyer_id,
    ct.name AS buyer_name,
    ct.vat_number AS buyer_vat_number,
    ct.registration_number AS buyer_registration_number,
    ct.address_line1 AS buyer_address_line1,
    ct.address_line2 AS buyer_address_line2,
    ct.postal_code AS buyer_postal_code,
    ct.city AS buyer_city,
    ct.country AS buyer_country,
    ct.region AS buyer_region,
    ct.email AS buyer_email,
    c.fiscal_country AS country,
    cd.number_format,
    cd.numbering_gapless,
    cd.legal_payment_days,
    cd.late_payment_reference,
    cd.tax_point_rule,
    cd.einvoice_profile,
    cd.einvoice_mandatory_from,
    cd.party_scheme,
    cd.vat_scheme,
    d.language,
    d.tax_point_date,
    d.delivery_address_line1,
    d.delivery_postal_code,
    d.delivery_city,
    d.delivery_country,
    c.peppol_scheme AS seller_peppol_scheme,
    c.peppol_identifier AS seller_peppol_identifier,
    ct.peppol_scheme AS buyer_peppol_scheme,
    ct.peppol_identifier AS buyer_peppol_identifier,
    c.activity_description AS seller_activity_description,
    c.identifiers AS seller_identifiers,
    ct.identifiers AS buyer_identifiers,
    ct.phone AS buyer_phone
   FROM documents d
     JOIN companies c ON c.id = d.company_id
     JOIN contacts ct ON ct.id = d.contact_id
     LEFT JOIN bank_accounts seller_bank ON seller_bank.id = c.default_bank_account_id
     LEFT JOIN country_defaults cd ON cd.country = c.fiscal_country;

comment on view ekwo.document_header is
  'One document with everything printed above its lines: the seller, the buyer, the amounts, where it is paid, what its country requires, the language it is written in, the tax point and the delivery where they were stated, the electronic address of both parties, and the identifiers by scheme a format cleared by the tax authority asks of them (seller_identifiers, buyer_identifiers, seller_activity_description, buyer_phone). The lines are document_line_items and the sentences are document_legal_mentions.';

revoke all on table ekwo.document_header from public, anon;
grant select on table ekwo.document_header to authenticated, service_role;

create view ekwo.document_line_items
  with (security_invoker = true) as
 SELECT l.id AS document_line_id,
    l.document_id,
    l.company_id,
    l.sequence,
    l.line_type,
    l.name AS item_name,
    l.description AS item_description,
    p.code AS seller_item_identifier,
    l.product_id,
    p.kind AS product_kind,
    l.quantity,
    l.unit_code,
    l.unit_price,
    l.discount_percent,
    l.amount_untaxed,
    l.tax_id,
    l.vat_category,
    l.vat_rate,
    l.account_id,
    t.treatment AS tax_treatment,
    t.exemption_code AS tax_exemption_code,
    t.cash_basis AS tax_cash_basis,
    l.unit_price_includes_tax,
    l.amount_incl_tax,
    l.attributes,
    l.stated_tax_amount
   FROM document_lines l
     LEFT JOIN products p ON p.id = l.product_id
     LEFT JOIN taxes t ON t.id = l.tax_id;

comment on view ekwo.document_line_items is
  'Document lines with the EN 16931 item terms — BT-153 name, BT-154 description, BT-155 the seller identifier — what decides a legal mention on the line, and, where the price was quoted with the tax in it, the gross it was quoted at. unit_price is the price as keyed, which is that gross: BT-146 is the net price and this view does not publish it yet. attributes is what an electronic invoice format asks of the line that no other column says, by name. stated_tax_amount is the tax the source of the document states for the line, where it states one (decision 0099).';

revoke all on table ekwo.document_line_items from public, anon;
grant select on table ekwo.document_line_items to authenticated, service_role;

create view ekwo.document_tax_summary
  with (security_invoker = true) as
 SELECT document_id,
    company_id,
    doc_type,
    tax_id,
    tax_code,
    tax_name,
    vat_category,
    tax_rate,
    base_amount,
    COALESCE(stated_tax, computed_tax) AS tax_amount,
        CASE
            WHEN stated_tax IS NULL THEN computed_charged
            ELSE round_amount(stated_tax * charge_factor / 100::numeric, rounding)
        END AS tax_charged,
    exemption_code,
    exemption_reason,
    legal_reference,
    base_includes_tax,
    base_amount +
        CASE
            WHEN base_includes_tax THEN COALESCE(stated_tax, computed_tax)
            ELSE 0::numeric
        END AS taxable_amount,
    computed_tax AS tax_amount_computed,
    stated_tax AS stated_tax_amount,
    line_count
   FROM ( SELECT l.document_id,
            l.company_id,
            d.doc_type,
            l.tax_id,
            t.code AS tax_code,
            t.name AS tax_name,
            l.vat_category,
            l.vat_rate::numeric(12,4) AS tax_rate,
            sum(l.amount_untaxed) AS base_amount,
            round_amount(tax_amount_of(
                CASE
                    WHEN bool_and(l.unit_price_includes_tax) THEN sum(l.amount_incl_tax)
                    ELSE sum(l.amount_untaxed)
                END, l.vat_rate, bool_and(l.unit_price_includes_tax), bool_and(l.base_includes_tax)), rounding_of(l.company_id, d.currency_code::text)) AS computed_tax,
            round_amount(tax_amount_of(
                CASE
                    WHEN bool_and(l.unit_price_includes_tax) THEN sum(l.amount_incl_tax)
                    ELSE sum(l.amount_untaxed)
                END, l.vat_rate, bool_and(l.unit_price_includes_tax), bool_and(l.base_includes_tax)) * COALESCE(( SELECT sum(tp.factor_percent) AS sum
                   FROM tax_postings tp
                  WHERE tp.tax_id = t.id AND (tp.posting_type = ANY (ARRAY['tax'::tax_posting_type, 'tax_on_base'::tax_posting_type])) AND tp.document_kind =
                        CASE
                            WHEN d.doc_type = ANY (ARRAY['sale_credit_note'::doc_type, 'purchase_credit_note'::doc_type]) THEN 'credit_note'::tax_document_kind
                            ELSE 'invoice'::tax_document_kind
                        END), 100::numeric) / 100::numeric, rounding_of(l.company_id, d.currency_code::text)) AS computed_charged,
            COALESCE(( SELECT sum(tp.factor_percent) AS sum
                   FROM tax_postings tp
                  WHERE tp.tax_id = t.id AND (tp.posting_type = ANY (ARRAY['tax'::tax_posting_type, 'tax_on_base'::tax_posting_type])) AND tp.document_kind =
                        CASE
                            WHEN d.doc_type = ANY (ARRAY['sale_credit_note'::doc_type, 'purchase_credit_note'::doc_type]) THEN 'credit_note'::tax_document_kind
                            ELSE 'invoice'::tax_document_kind
                        END), 100::numeric) AS charge_factor,
            rounding_of(l.company_id, d.currency_code::text) AS rounding,
            t.exemption_code,
            ( SELECT string_agg(label_for(m.text, m.text_i18n, preferred_languages(d.language::text, d.company_id)), ' '::text ORDER BY m.sequence, m.code) AS string_agg
                   FROM legal_mention_templates m
                     JOIN companies c ON c.id = d.company_id
                  WHERE m.country = c.fiscal_country AND m.valid_from <= d.document_date AND (m.valid_to IS NULL OR m.valid_to >= d.document_date) AND (t.treatment::text = ANY (legal_mention_treatments(m.applies_when)))) AS exemption_reason,
            t.legal_reference,
            bool_and(l.base_includes_tax) AS base_includes_tax,
                CASE
                    WHEN count(l.stated_tax_amount) = count(*) THEN sum(l.stated_tax_amount)
                    ELSE NULL::numeric
                END AS stated_tax,
            count(*)::integer AS line_count
           FROM document_lines l
             JOIN documents d ON d.id = l.document_id
             LEFT JOIN taxes t ON t.id = l.tax_id
          WHERE l.line_type = 'product'::document_line_type
          GROUP BY l.document_id, l.company_id, d.id, l.tax_id, t.id, l.vat_category, l.vat_rate) g;

comment on view ekwo.document_tax_summary is
  'VAT breakdown of a document, one row per tax, rounded once on the group (EN 16931 BR-CO-14) — on the group''s base, or on the gross it was quoted at where the price includes the tax — unless the source of the document states the tax of the group: then tax_amount is the stated one (the sum of stated_tax_amount on every line of the group), accepted at posting within stated_tax_tolerance() of tax_amount_computed, which is Ekwo''s figure (decision 0099). The category and the rate are the ones the lines carry: the tax of today for a draft, the tax as it stood for a document that was posted. Where the tax charges nothing it says why: exemption_code is BT-121 as the pack codes it, exemption_reason is BT-120 — the sentence the country puts on an invoice for that treatment, in the language of the document, null where the pack has none. legal_reference is the article the tax rests on, written for whoever reviews the pack and not for a customer. base_includes_tax says the tax was computed inside its own base, and taxable_amount is the base the rate was applied to: base_amount plus the tax where it was, base_amount where it was not (decision 0077). line_count is the number of lines of the group.';

revoke all on table ekwo.document_tax_summary from public, anon;
grant select on table ekwo.document_tax_summary to authenticated, service_role;

create view ekwo.bank_statement_continuity
  with (security_invoker = true) as
 SELECT s.id AS statement_id,
    s.company_id,
    s.bank_account_id,
    s.statement_ref,
    s.sequence_number,
    COALESCE(s.period_start, s.statement_date) AS period_start,
    s.statement_date,
    s.balance_start,
    p.id AS previous_statement_id,
    p.statement_ref AS previous_statement_ref,
    p.statement_date AS previous_statement_date,
    p.balance_end_declared AS previous_balance_end,
    s.balance_start - p.balance_end_declared AS balance_gap,
        CASE
            WHEN s.sequence_number IS NULL OR p.sequence_number IS NULL THEN NULL::numeric
            WHEN EXTRACT(year FROM s.statement_date) > EXTRACT(year FROM p.statement_date) AND s.sequence_number <= p.sequence_number THEN GREATEST(s.sequence_number - 1::numeric, 0::numeric)
            ELSE s.sequence_number - p.sequence_number - 1::numeric
        END AS missing_statements,
    p.id IS NOT NULL AND s.balance_start <> p.balance_end_declared AS is_broken,
    p.sequence_number AS previous_sequence_number
   FROM bank_statements s
     LEFT JOIN LATERAL ( SELECT q.id,
            q.company_id,
            q.bank_account_id,
            q.name,
            q.statement_date,
            q.balance_start,
            q.balance_end_declared,
            q.balance_end_computed,
            q.is_consistent,
            q.state,
            q.source,
            q.created_at,
            q.updated_at,
            q.statement_ref,
            q.sequence_number,
            q.period_start,
            q.source_format,
            q.source_file_name,
            q.source_checksum
           FROM bank_statements q
          WHERE q.bank_account_id = s.bank_account_id AND q.id <> s.id AND q.statement_date <= COALESCE(s.period_start, s.statement_date) AND COALESCE(q.period_start, q.statement_date) < COALESCE(s.period_start, s.statement_date)
          ORDER BY q.statement_date DESC, (COALESCE(q.period_start, q.statement_date)) DESC, q.created_at DESC
         LIMIT 1) p ON true;

comment on view ekwo.bank_statement_continuity is
  'Each statement beside the one before it on the same account: whether its opening balance is the closing balance of the previous one (`is_broken`, `balance_gap`), and how many statements the bank numbered in between (`missing_statements`) — counted within the year when the numbering starts again from 1 in a later year, as CODA''s does. A break is shown and never refused: the statement that is there is still true, and the one that is missing can only be seen from here.';

revoke all on table ekwo.bank_statement_continuity from public, anon;
grant select on table ekwo.bank_statement_continuity to authenticated, service_role;

