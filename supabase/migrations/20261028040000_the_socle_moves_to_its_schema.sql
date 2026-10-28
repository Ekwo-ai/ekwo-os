-- Ekwo OS — the socle moves out of `public` into its own schema, `ekwo`.
--
-- The second half of decision 0090. `20261025072151` created the schema,
-- empty, with the rights `public` carries; this file fills it. Every object
-- of the socle — its tables, its views, its types, its functions, and the one
-- sequence no table owns — leaves `public` for `ekwo` with `alter … set
-- schema`, which keeps the identity of each: foreign keys, indexes, policies,
-- triggers, privileges, defaults, comments and the views over a table stay as
-- they were. `public` is left to whoever else shares the database.
--
-- **By the exact list, never "everything in `public`."** The names below are
-- the inventory of the release that wrote this file (`npm run inventory`,
-- decision 0058). A database that carries another application beside Ekwo OS
-- keeps that application's tables where they are. A name of the list that is
-- not in `public` is skipped: an installation that moved the socle by hand
-- ends in the same state.
--
-- **What `alter … set schema` does not rewrite is text.** A function names
-- the socle in its own `search_path` (`set search_path = public, pg_temp`,
-- the shape of this directory) and, here and there, in its body
-- (`public.companies`, `'public'::name`). So after the move every function
-- of the socle and of the installed modules whose settings or body name
-- `public` is read back from the catalogue and written again with `ekwo` in
-- its place: `public.<name>` becomes `ekwo.<name>`, and the string `'public'`
-- becomes `'ekwo'` — in a `search_path` setting and in the four functions of
-- the archive that compare a schema by name. A module's function stays in the
-- module's schema; only the socle it names moves. This is the recreation the
-- decision announces, and it changes no signature, no owner, no grant.
--
-- **An archive keeps its former names readable.** An archive written before
-- this file files its rows under `public.<table>`; the registry an export
-- reads said `public` too. The registry is moved, and
-- `archive_under_current_names()` learns the socle's former schema beside the
-- former names of the modules: a `public.<table>` of the socle is read as
-- `ekwo.<table>`, so the archives already kept import as before.
--
-- **PostgREST.** The request hook moves with its function:
-- `pgrst.db_pre_request` on the `authenticator` role names
-- `ekwo.ekwo_pre_request` from here on, the same way `20260922160000` set it,
-- with the same notice where the role cannot be altered. The schemas the Data
-- API serves are a setting of the project and not of the database: `ekwo`
-- was to be exposed before this file ran (`ekwo migrate` and `ekwo doctor`
-- have said so since 0.21.0), and a call that reaches the API names the
-- schema by its profile (decision 0090).
--
-- **The path.** The connection that runs this file continues with `ekwo`
-- first on its `search_path`, so the files that follow it in the same run and
-- the seeds land in the socle wherever they are written unqualified. The
-- owner's role gets the same default for the SQL written by hand, where the
-- role can be altered. Nothing of the kind is needed by the packages: they
-- find the socle by its marker, `ekwo_schema_version()`, and name the schema
-- on every call.
--
-- The floor of the packages does not move: a database before this file is
-- read exactly as before. A client older than this release reads `public`
-- and finds nothing there: `@latest` is the rule for the command line and the
-- MCP server.

-- ---------------------------------------------------------------------------
-- 0. Both schemas on the path while the objects move
--
-- A function's signature names its argument types, and those types move in
-- this file too: with both schemas on the path every name resolves whichever
-- side of the move it is on. The path of this connection is set again at the
-- end.
-- ---------------------------------------------------------------------------

select set_config('search_path', 'public, ekwo, ' || current_setting('search_path'), false);

-- ---------------------------------------------------------------------------
-- 1. The tables, with their indexes, policies, triggers and owned sequences
-- ---------------------------------------------------------------------------

do $$
declare
  v_name text;
begin
  foreach v_name in array array[
      'account_templates', 'accounts', 'analysis_aggregates', 'analysis_rules', 'analysis_templates', 'analytic_axes',
      'analytic_values', 'api_keys', 'attachments', 'audit_log', 'bank_accounts', 'bank_statement_lines',
      'bank_statements', 'bank_transactions', 'book_imports', 'capabilities', 'chart_templates', 'classification_schemes',
      'companies', 'company_archive_registry', 'company_filing_periods', 'company_invitations', 'company_members', 'company_modules',
      'company_packs', 'company_tax_regimes', 'company_vat_schemes', 'contact_merges', 'contact_patterns', 'contacts',
      'country_defaults', 'country_packs', 'currencies', 'currency_rates', 'declaration_instalments', 'document_line_analytics',
      'document_lines', 'document_shares', 'document_unpostings', 'documents', 'entries', 'entry_line_analytics',
      'entry_lines', 'filing_proofs', 'fiscal_years', 'instance', 'instance_admins', 'journal_sequences',
      'journal_templates', 'journals', 'legal_mention_templates', 'lines_left_unnamed', 'matching_sequences', 'matching_settings',
      'modules', 'payments', 'products', 'reconciliation_batches', 'reconciliations', 'role_capabilities',
      'statement_line_rules', 'statement_line_templates', 'statement_templates', 'tax_filing_boxes', 'tax_filing_deposits', 'tax_filings',
      'tax_posting_templates', 'tax_postings', 'tax_report_box_templates', 'tax_report_templates', 'tax_templates', 'taxes',
      'territories', 'turnover_tax_assessments', 'turnover_tax_brackets', 'turnover_tax_regimes', 'user_preferences', 'vat_scheme_ceilings',
      'vat_scheme_forms', 'vat_scheme_instalments', 'vat_schemes'
    ]
  loop
    if to_regclass(format('public.%I', v_name)) is not null then
      execute format('alter table public.%I set schema ekwo', v_name);
    end if;
  end loop;
end $$;

-- The audit log numbers its rows from a sequence of its own, owned by no
-- column (`20260911210131`): the one sequence that does not move with a table.
do $$
begin
  if to_regclass('public.audit_log_id_seq') is not null then
    alter sequence public.audit_log_id_seq set schema ekwo;
  end if;
end $$;

-- ---------------------------------------------------------------------------
-- 2. The views
-- ---------------------------------------------------------------------------

do $$
declare
  v_name text;
begin
  foreach v_name in array array[
      'api_key_reach', 'bank_statement_continuity', 'document_header', 'document_legal_mentions', 'document_line_items', 'document_tax_summary'
    ]
  loop
    if to_regclass(format('public.%I', v_name)) is not null then
      execute format('alter view public.%I set schema ekwo', v_name);
    end if;
  end loop;
end $$;

-- ---------------------------------------------------------------------------
-- 3. The types: the enums, and the two composite types the policies read
-- ---------------------------------------------------------------------------

do $$
declare
  v_name text;
begin
  foreach v_name in array array[
      'account_type', 'audit_operation', 'bank_statement_state', 'bank_transaction_state', 'closing_style', 'contact_pattern_kind',
      'contact_pattern_source', 'contact_type', 'declaration_period', 'doc_state', 'doc_type', 'document_line_type',
      'entry_kind', 'entry_state', 'eu_vat_scope', 'filing_channel', 'filing_deadline_rule', 'filing_proof_method',
      'filing_proof_status', 'filing_proof_subject', 'instance_edition', 'journal_type', 'matching_policy', 'member_role',
      'module_status', 'money_rounding', 'pack_certification', 'pack_change_rule', 'payment_direction', 'payment_state',
      'payment_state_t', 'product_kind', 'rounding_method', 'share_subject_kind', 'tax_amount_type', 'tax_condition',
      'tax_credit_treatment', 'tax_document_kind', 'tax_filing_state', 'tax_kind', 'tax_posting_type', 'tax_scope',
      'tax_treatment', 'territory_code_source', 'territory_relation'
    ]
  loop
    if to_regtype(format('public.%I', v_name)) is not null then
      execute format('alter type public.%I set schema ekwo', v_name);
    end if;
  end loop;
end $$;

-- ---------------------------------------------------------------------------
-- 4. The functions, every overload of each name
-- ---------------------------------------------------------------------------

do $$
declare
  v_routine record;
begin
  for v_routine in
    select p.oid::regprocedure as signature
      from pg_proc p
     where p.pronamespace = 'public'::regnamespace
       and p.proname = any(array[
      'accept_invitation', 'account_carries_analytics', 'account_id_by_code', 'account_key',
      'account_rule_catches', 'accounts_guard_frozen', 'accounts_in_use', 'acting_user',
      'aged_balance', 'agent_call', 'agent_mark', 'agent_posting_mode',
      'amount_text_format', 'analytic_axis_required_for', 'analytic_refresh_document_line', 'analytic_refresh_entry_line',
      'analytic_report', 'api_key_on_company', 'approve_document', 'archive_company',
      'archive_statement_timeout', 'archive_under_current_names', 'assert_analytic_account', 'assert_analytic_value_in_use',
      'assert_classifications', 'assert_company_live', 'assert_document_analytic_axes', 'assert_may_close_year',
      'assert_may_export_company', 'assert_may_post_document', 'assert_may_post_entry', 'assert_period_open',
      'assert_references_within_company', 'assert_writes_into_known_company', 'attachment_is_filing_deposit_file', 'attachments_guard_document',
      'audit_changes', 'audit_entry_posting', 'audit_log_is_append_only', 'audit_log_purge_is_recorded',
      'audit_log_refuses_truncate', 'audit_record', 'audit_state_change', 'authenticated_statement_timeout',
      'auto_settle', 'available_statements', 'bank_accounts_read_identifier', 'bank_statement_lines_refresh_balance',
      'bank_statement_movement', 'bank_statements_recompute', 'bank_statements_refresh_balance', 'bank_transactions_guard',
      'caller_companies', 'can_write_company', 'cancel_document', 'canonical_json',
      'catch_up_journal_sequence', 'claim_instance_admin', 'close_fiscal_year', 'close_fiscal_year_finally',
      'combination_subsets', 'commercial_entity', 'companies_agent_posting_by_a_person', 'companies_creator_is_fixed',
      'companies_default_bank_account_is_ours', 'companies_default_capital_currency', 'companies_guard_archived', 'companies_number_format_carries',
      'companies_number_format_is_valid', 'companies_vat_period_is_a_filing_period', 'companies_with_capability', 'company_archive_predicate',
      'company_archive_predicate_via', 'company_archive_row_count', 'company_archive_row_counts', 'company_archive_rows_query',
      'company_archive_tables', 'company_archive_unclassified', 'company_column', 'company_filing_periods_mirror',
      'company_filing_periods_names_a_form', 'company_filing_periods_within_scheme', 'company_has_no_member', 'company_members_capabilities_known',
      'company_members_join_of_their_own_accord', 'company_members_list', 'company_references_by_id', 'company_role',
      'company_scoped_tables', 'company_tax_regimes_check', 'company_vat_schemes_check', 'company_vat_schemes_follow',
      'confirm_contact', 'contact_candidates', 'contacts_guard_merged', 'contacts_language_reaches_drafts',
      'create_api_key', 'create_company', 'create_document', 'currency_of_bank_account',
      'currency_of_company', 'currency_unit', 'current_api_key', 'declaration_boxes_of',
      'declaration_period_months', 'declaration_period_of', 'declaration_period_start', 'declared_lines',
      'declared_on_of', 'default_statement_code', 'delete_company', 'disable_module',
      'document_amount_paid', 'document_line_analytics_guard', 'document_line_analytics_refresh', 'document_line_split_key',
      'document_lines_amount_untaxed', 'document_lines_analytic_defaults', 'document_lines_analytics_follow', 'document_lines_attributes_from_product',
      'document_lines_check_classifications', 'document_lines_guard_posted', 'document_lines_guard_tax_account', 'document_lines_refresh_totals',
      'document_lines_resolve_account', 'document_lines_snapshot_tax', 'document_share_refusal', 'document_territory',
      'document_version', 'documents_allocate_included_tax', 'documents_default_payee_iban', 'documents_guard_language',
      'documents_guard_posted', 'documents_match_credit_note_on_posting', 'documents_posting_mode', 'documents_refresh_amount_paid',
      'documents_refresh_payment_state', 'documents_refresh_totals', 'documents_refuse_replaced_tax', 'documents_refuse_vat_under_exemption',
      'ec_sales_list', 'ekwo_pre_request', 'ekwo_schema_version', 'enable_module',
      'entries_declared_on_follows', 'entries_guard_kind', 'entries_guard_module', 'entries_guard_period',
      'entries_guard_posted', 'entries_match_reversal_on_posting', 'entries_refresh_totals', 'entries_require_analytic_axes',
      'entry_line_analytics_guard', 'entry_line_analytics_refresh', 'entry_lines_analytics_follow', 'entry_lines_box_from_posting',
      'entry_lines_guard_period', 'entry_lines_guard_posted', 'entry_lines_set_declared_on', 'eu_vat_scope_of',
      'evaluate_totals', 'export_company', 'export_company_archive', 'export_company_manifest',
      'export_company_table', 'export_company_tables', 'fec_lines', 'file_filing',
      'filing_deadline', 'filing_drift', 'filing_period', 'filing_proof',
      'filing_rounding', 'filing_tax_movements', 'filings_touched_since', 'financial_analysis',
      'financial_statement', 'financial_statement_of_kind', 'fiscal_year_at', 'fiscal_year_bounds',
      'fiscal_year_final_close', 'fiscal_years_guard_closed', 'fiscal_years_guard_final', 'fiscal_years_no_overlap',
      'format_number', 'general_ledger', 'has_capability', 'has_opening_entry',
      'import_bank_statement', 'import_books', 'import_company', 'import_fiscal_year_for',
      'init_instance', 'install_country_template', 'installed_schema_version', 'instalment_plan',
      'instance_admins_keep_one', 'instance_has_no_admin', 'instance_is_shared', 'instance_sharing',
      'invite_member', 'is_any_company_member', 'is_archive_request', 'is_company_member',
      'is_company_owner', 'is_eu_member', 'is_installer', 'is_instance_admin',
      'is_known_caller', 'journal_book', 'journal_totals', 'journals_number_prefix_is_its_own',
      'key_holds', 'label_for', 'learn_contact_patterns', 'leave_line_unnamed',
      'legal_mention_treatments', 'line_contact_facts', 'locale_of_country_pack', 'lock_filed_period',
      'match_lines', 'match_reversal', 'matchable_lines', 'matching_difference_reasons',
      'matching_difference_tolerance', 'matching_policy_of', 'matching_search_bounds', 'may_know_of_company',
      'may_match_on_posting', 'member_capabilities', 'member_holds', 'merge_contacts',
      'module_enabled', 'module_entry_id', 'module_is_enabled', 'module_settings',
      'name_agreement', 'name_among_several', 'next_entry_number', 'next_matching_number',
      'note_company_export', 'number_counter', 'numbering_rules', 'open_items',
      'opening_balance', 'opening_journal_id', 'pack_upgrade', 'pack_upgrade_diff',
      'party_identifier', 'periodic_return_code', 'pin_referenced_accounts', 'portfolio_filings_touched_since',
      'portfolio_upcoming_filings', 'post_document', 'post_entry', 'post_module_entry',
      'post_payment', 'post_turnover_tax', 'posted_edit_policy', 'preferred_languages',
      'prepare_filing', 'present_api_key', 'product_report', 'products_check_classifications',
      'purge_audit_log', 'reconcile', 'reconcile_batch', 'reconcile_many',
      'reconcile_with_difference', 'reconciliation_batches_guard', 'reconciliations_guard_cancelled', 'reconciliations_guard_reconcile',
      'reconciliations_refresh_lines', 'record_filing_files', 'record_filing_outcome', 'record_filing_proof',
      'refuse_merged_contact', 'refuse_merged_contacts_in', 'register_instance', 'rehearse_post_document',
      'remove_member', 'reopen_filing', 'reopen_fiscal_year', 'replace_document_lines',
      'resolve_counterpart_account', 'resolve_line_account', 'reverse_entry', 'revoke_api_key',
      'revoke_invitation', 'revoke_share', 'round_amount', 'rounding_of',
      'scope_references_to_company', 'set_line_contact', 'set_member_role', 'set_preferences',
      'set_updated_at', 'settle_cash_basis_tax', 'settle_filing', 'settle_from_statement',
      'share_document', 'share_instance', 'shared_document', 'significant_words',
      'statement_account_matches', 'statement_figures', 'statement_rule_catches', 'suggest_combination',
      'suggest_contacts', 'suggest_duplicate_contacts', 'suggest_item_combinations', 'suggest_line_contacts',
      'suggest_matches', 'suggest_sure_pairs', 'supersede_filing', 'tax_amount_of',
      'tax_filing_boxes_are_frozen', 'tax_filing_deposits_files_are_its_own', 'tax_filing_values_sha256', 'tax_filings_paid_by_matching',
      'tax_filings_report_exists', 'tax_payee', 'tax_point_of', 'tax_posting_boxes_agree',
      'tax_rate_at', 'taxes_reach_draft_lines', 'territory_of', 'territory_within',
      'territory_within_for_tax', 'touch_api_key', 'trial_balance', 'turnover_of',
      'turnover_tax_regime_at', 'turnover_tax_return', 'unarchive_company', 'undo_leave_line_unnamed',
      'unmapped_accounts', 'unpost_document', 'unpost_refusal', 'unreconcile',
      'unreconcile_batch', 'unregister_instance', 'unshare_instance', 'upcoming_filings',
      'upgrade_filing_proof', 'use_api_key', 'user_preferences_company_is_known', 'vat_prefix_of',
      'vat_return', 'vat_scheme_at', 'vat_scheme_ceilings_crossed', 'vat_scheme_files',
      'version_at_least', 'write_filing_outcome', 'year_result_account'
       ])
     order by p.proname, p.oid
  loop
    execute format('alter function %s set schema ekwo', v_routine.signature);
  end loop;
end $$;

-- ---------------------------------------------------------------------------
-- 5. The functions that name `public` are written again with `ekwo`
--
-- Read back from the catalogue as `create or replace function`, which keeps
-- the identity, the owner, the privileges and the comment of each. Two
-- rewrites, both on the text Postgres prints: `public.<name>` — a table, a
-- type or a function the body qualifies, a `'public.x'::regclass` — becomes
-- `ekwo.<name>`, and the string `'public'` — the `search_path` setting of the
-- function, the schema the archive functions compare — becomes `'ekwo'`. A
-- sentence that ends with the word "public." is left alone: only a name
-- follows the dot that is rewritten.
--
-- The functions of the installed modules go through the same reading: a
-- module names the socle by `public.companies` and carries
-- `search_path = public, pg_temp` (decision 0051), and its schema is read from
-- the registry rather than assumed.
-- ---------------------------------------------------------------------------

do $$
declare
  v_schema  text;
  v_routine record;
  v_source  text;
  v_written text;
  v_count   integer := 0;
begin
  for v_schema in
    select 'ekwo' union all select m.schema_name from ekwo.modules m order by 1
  loop
    continue when to_regnamespace(v_schema) is null;
    for v_routine in
      select p.oid, p.oid::regprocedure as signature
        from pg_proc p
       where p.pronamespace = to_regnamespace(v_schema)
         and p.prokind = 'f'
         and (p.prosrc ~ 'public\.[a-z_]' or p.prosrc ~ '''public'''
              or exists (select 1 from unnest(p.proconfig) c where c ~ 'public'))
       order by p.proname, p.oid
    loop
      v_source  := pg_get_functiondef(v_routine.oid);
      v_written := regexp_replace(v_source, 'public\.([a-z_])', 'ekwo.\1', 'g');
      v_written := regexp_replace(v_written, '''public''', '''ekwo''', 'g');
      if v_written <> v_source then
        execute v_written;
        v_count := v_count + 1;
      end if;
    end loop;
  end loop;
  raise notice 'ekwo: % function(s) written again with the socle in ekwo', v_count;
end $$;

-- A function of the socle that carried no path of its own resolved its names
-- by the path of the session, which was `public` on every connection and
-- every request. A request served under a module's profile has the module on
-- its path and the socle no longer, and a policy of the module that folds
-- `module_enabled()` into its query then fails to find `is_company_member()`.
-- So a function of the socle carries its path from here on, `ekwo` first —
-- every one written in plpgsql, and the SQL helpers a policy folds in, which
-- the planner then calls per row instead of inlining. The other SQL functions,
-- the readers a report folds into one plan — `declared_lines()`,
-- `filing_tax_movements()` — keep no path and stay inlined: they run under
-- the profile `ekwo` or inside a function that carries the path, and
-- `tests/load` holds the planner to its indexes. A function that had a path
-- keeps it, rewritten above.
do $$
declare
  v_routine record;
  v_count   integer := 0;
begin
  for v_routine in
    select p.oid::regprocedure as signature
      from pg_proc p
      join pg_language l on l.oid = p.prolang
     where p.pronamespace = 'ekwo'::regnamespace
       and p.prokind = 'f'
       and not exists (select 1 from unnest(p.proconfig) c where c like 'search_path=%')
       and (l.lanname <> 'sql'
            or exists (select 1 from pg_policy q
                        where pg_get_expr(q.polqual, q.polrelid) ~ ('\m' || p.proname || '\(')
                           or pg_get_expr(q.polwithcheck, q.polrelid) ~ ('\m' || p.proname || '\(')))
     order by p.proname, p.oid
  loop
    execute format('alter function %s set search_path = ekwo, pg_temp', v_routine.signature);
    v_count := v_count + 1;
  end loop;
  raise notice 'ekwo: % function(s) of the socle given a search_path', v_count;
end $$;

-- A function of a module that carried no path of its own read the socle
-- through the path of the request — `public`, which every request had — and
-- so did what it called: the socle's functions without a path of their own,
-- and the triggers of the socle's tables. It carries its path from here on:
-- its own schema first, then the socle's, for as long as it runs, nested
-- calls and triggers included. A function that had a path keeps it, rewritten
-- above. The modules installed after this file get the same from the
-- installer, which calls this function once a module's migrations have run;
-- a module function written today says it in its own file. The function
-- also gives the path to the SQL helpers of the socle the module's policies
-- fold into their queries — `module_enabled()` on a fresh installation, where
-- the modules arrive after this file and no policy named it yet.
create or replace function ekwo.module_functions_follow_the_socle(p_schema text)
returns integer
language plpgsql
set search_path = ekwo, pg_temp
as $$
declare
  v_routine record;
  v_count   integer := 0;
begin
  if to_regnamespace(p_schema) is null then
    return 0;
  end if;
  for v_routine in
    select p.oid::regprocedure as signature
      from pg_proc p
     where p.pronamespace = to_regnamespace(p_schema)
       and p.prokind = 'f'
       and not exists (select 1 from unnest(p.proconfig) c where c like 'search_path=%')
     order by p.proname, p.oid
  loop
    execute format('alter function %s set search_path = %I, ekwo, pg_temp', v_routine.signature, p_schema);
    v_count := v_count + 1;
  end loop;
  for v_routine in
    select p.oid::regprocedure as signature
      from pg_proc p
      join pg_language l on l.oid = p.prolang
     where p.pronamespace = 'ekwo'::regnamespace
       and p.prokind = 'f'
       and l.lanname = 'sql'
       and not exists (select 1 from unnest(p.proconfig) c where c like 'search_path=%')
       and exists (select 1 from pg_policy q join pg_class c on c.oid = q.polrelid
                    where c.relnamespace = to_regnamespace(p_schema)
                      and (pg_get_expr(q.polqual, q.polrelid) ~ ('\m' || p.proname || '\(')
                        or pg_get_expr(q.polwithcheck, q.polrelid) ~ ('\m' || p.proname || '\(')))
     order by p.proname, p.oid
  loop
    execute format('alter function %s set search_path = ekwo, pg_temp', v_routine.signature);
    v_count := v_count + 1;
  end loop;
  return v_count;
end;
$$;

comment on function ekwo.module_functions_follow_the_socle(text) is
  'Gives every function of a module''s schema that carries no search_path one of its own — the module''s schema, then ekwo — and the same to the SQL helpers of the socle the module''s policies fold in, so that what runs under a request served with the module''s profile finds the socle. Called by the installer after a module''s migrations; answers how many were set. Owner only.';

do $$
declare
  v_schema text;
begin
  for v_schema in select m.schema_name from ekwo.modules m order by 1 loop
    perform ekwo.module_functions_follow_the_socle(v_schema);
  end loop;
end $$;

-- ---------------------------------------------------------------------------
-- 6. The archives written before the move keep their names readable
--
-- The registry an export reads named the socle's tables under `public`; it
-- names them under `ekwo` from here on, so a new archive is filed under the
-- names of today. `archive_under_current_names()` — written again as
-- `20260929151700` left it, the rewrite of step 5 included — learns the
-- socle's former schema first: a table of an archive filed as
-- `public.<table>` where `ekwo.<table>` is a table of the socle is read as
-- the latter, rows and manifest alike. The modules' former names follow, as
-- before.
-- ---------------------------------------------------------------------------

update ekwo.company_archive_registry
   set table_schema = 'ekwo'
 where table_schema = 'public'
   and to_regclass(format('ekwo.%I', table_name)) is not null;

-- A row written from here on names the socle's schema by default, as the
-- rows the socle wrote did; a row that reaches its company through another
-- table names that table (`via_table`), and named it `public.journals`.
alter table ekwo.company_archive_registry alter column table_schema set default 'ekwo';

update ekwo.company_archive_registry
   set via_table = 'ekwo.' || substr(via_table, length('public.') + 1)
 where via_table like 'public.%'
   and to_regclass('ekwo.' || substr(via_table, length('public.') + 1)) is not null;

create or replace function ekwo.archive_under_current_names(p_archive jsonb)
returns jsonb
language plpgsql
stable
set search_path = ekwo, pg_temp
as $$
declare
  v_out    jsonb := p_archive;
  v_module record;
  v_rename record;
  v_key    text;
  v_table  text;
  v_now    text;
begin
  -- The socle's former schema. A key `public.<table>` of a table the socle
  -- holds in `ekwo` is read under the latter; a table of the archive that is
  -- not of the socle keeps its name, and import_company() says what it does
  -- not know.
  for v_key in select k from jsonb_object_keys(coalesce(v_out -> 'tables', '{}'::jsonb)) as k order by k loop
    continue when v_key !~ '^public\.';
    v_table := substr(v_key, 8);
    continue when to_regclass(format('ekwo.%I', v_table)) is null;
    v_now := 'ekwo.' || v_table;
    if v_out -> 'tables' ? v_now then
      raise exception 'archive_corrupt: the archive carries both % and %, which are one table under two names',
        v_key, v_now;
    end if;
    v_out := jsonb_set(v_out, '{tables}',
               ((v_out -> 'tables') - v_key) || jsonb_build_object(v_now, v_out -> 'tables' -> v_key));
    if jsonb_typeof(v_out #> '{manifest,tables}') = 'array'
       and exists (select 1 from jsonb_array_elements(v_out #> '{manifest,tables}') m where m ->> 'name' = v_key) then
      v_out := jsonb_set(v_out, '{manifest,tables}', (
        select jsonb_agg(case when m ->> 'name' = v_key then jsonb_set(m, '{name}', to_jsonb(v_now)) else m end order by n)
          from jsonb_array_elements(v_out #> '{manifest,tables}') with ordinality as x(m, n)));
    end if;
  end loop;

  for v_module in select m.code, m.schema_name from modules m order by m.code loop
    continue when to_regprocedure(format('%I.archive_former_names()', v_module.schema_name)) is null;
    for v_rename in
      execute format('select former_name, current_name from %I.archive_former_names()', v_module.schema_name)
    loop
      if coalesce(v_out -> 'tables' ? v_rename.former_name, false) then
        if v_out -> 'tables' ? v_rename.current_name then
          raise exception 'archive_corrupt: the archive carries both % and %, which are one table under two names',
            v_rename.former_name, v_rename.current_name;
        end if;
        v_out := jsonb_set(v_out, '{tables}',
                   ((v_out -> 'tables') - v_rename.former_name)
                   || jsonb_build_object(v_rename.current_name, v_out -> 'tables' -> v_rename.former_name));
      end if;

      if jsonb_typeof(v_out #> '{manifest,tables}') = 'array'
         and exists (select 1 from jsonb_array_elements(v_out #> '{manifest,tables}') m
                      where m ->> 'name' = v_rename.former_name) then
        v_out := jsonb_set(v_out, '{manifest,tables}', (
          select jsonb_agg(case when m ->> 'name' = v_rename.former_name
                                then jsonb_set(m, '{name}', to_jsonb(v_rename.current_name))
                                else m end
                           order by n)
            from jsonb_array_elements(v_out #> '{manifest,tables}') with ordinality as x(m, n)));
      end if;
    end loop;
  end loop;
  return v_out;
end;
$$;

comment on function ekwo.archive_under_current_names(jsonb) is
  'The archive with its tables and its manifest filed under the names of today: a `public.<table>` of the socle read as `ekwo.<table>`, then a former name of a module (`<schema>.archive_former_names()`) read as its current one. An archive carrying one table under two names is refused.';

-- ---------------------------------------------------------------------------
-- 7. PostgREST calls the request hook where it now lives
--
-- The same setting `20260922160000` made, on the same role, with the same
-- way out where the role cannot be altered from here.
-- ---------------------------------------------------------------------------

do $$
begin
  if exists (select 1 from pg_roles where rolname = 'authenticator') then
    begin
      execute 'alter role authenticator set pgrst.db_pre_request = ''ekwo.ekwo_pre_request''';
    exception when insufficient_privilege or object_not_in_prerequisite_state then
      raise notice 'ekwo: could not set pgrst.db_pre_request on the authenticator role. Machine keys will not be read from X-Ekwo-Api-Key until somebody with the privilege runs: alter role authenticator set pgrst.db_pre_request = ''ekwo.ekwo_pre_request''; notify pgrst, ''reload config''; — `ekwo doctor` reports this.';
    end;
  end if;
end $$;

-- ---------------------------------------------------------------------------
-- 8. The path: this connection, and the owner's role for SQL written by hand
--
-- The connection that runs this file goes on with the socle first on its
-- path: the migrations that follow in the same run and the seeds, written
-- unqualified, land in `ekwo`. The owner's role gets the same default, so a
-- `select … from companies` typed against the database keeps answering for
-- one release at least (decision 0090); where the role cannot be altered,
-- the SQL names `ekwo.<table>`.
-- ---------------------------------------------------------------------------

do $$
begin
  begin
    execute format('alter role %I set search_path = ekwo, "$user", public, extensions', current_user);
  exception when others then
    raise notice 'ekwo: the search_path of the role % was left as it is; SQL written by hand names ekwo.<table>', current_user;
  end;
end $$;

select set_config('search_path', 'ekwo, ' || current_setting('search_path'), false);

-- ---------------------------------------------------------------------------
-- 9. The schema says what it holds, and keeps the rule every file ends with
-- ---------------------------------------------------------------------------

comment on schema ekwo is
  'The socle of Ekwo OS: the companies, the ledger, the documents, the taxes, the reports and every function that guards them (decision 0090).';

revoke execute on all functions in schema ekwo from public;
