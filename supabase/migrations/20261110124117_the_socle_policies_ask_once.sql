-- Ekwo OS — the socle's last policies ask once per statement, not once per row.
--
-- `20260918141627_a_policy_asks_once.sql` rewrote every policy of the socle
-- whose `using` was exactly `has_capability(company_id, '<capability>')` into
--
--     using (company_id = any ((select companies_with_capability('<capability>'))::uuid[]))
--
-- — a sub-select that depends on no column, an InitPlan, run once per
-- statement — and left the policies that were not that shape. The modules
-- followed (`modules/*/supabase/migrations/*_policies_ask_once.sql`), and
-- `tests/policies_ask_once.test.ts` now refuses any `using` that calls a
-- function of the database with a column of the row. Seventeen policies of
-- the socle were left on its list. This file rewrites fifteen of them; the
-- two it leaves are named at the end, with the reason.
--
-- ---------------------------------------------------------------------------
-- The shapes, and what each becomes
--
-- **`is_company_member(company_id)`** had no "companies where" counterpart.
-- `companies_of_caller()` is that counterpart: the companies where
-- `is_company_member()` answers yes, as an array. It does not restate what
-- membership is. It lists the only companies where the answer can be yes —
-- those the caller is a member of, and the one a presented machine key
-- belongs to — and asks `is_company_member()` about each, exactly as
-- `companies_with_capability()` lists the same candidates and asks
-- `has_capability()`. A change to what membership means changes both.
-- Five select policies read only that (`company_filing_periods`,
-- `company_modules`, `company_tax_regimes`, `company_vat_schemes`,
-- `matching_settings`), and two more combine it with something else
-- (`companies`, `company_members`).
--
-- **A term that depends on no column** — `is_instance_admin()` — stays a
-- term, `or`-ed with the InitPlan form. It is written `(select
-- is_instance_admin())`, which is the same boolean asked once per statement
-- rather than once per row a scan visits: it is security definer and probes
-- an index each time it is called. The `or` is unchanged.
--
-- **`user_id = auth.uid()`** and **`uploaded_by = auth.uid()`** are kept as
-- they are: `auth.uid()` takes no column, reads the claims of the session and
-- no table, and the inventory does not count it as a per-row question.
--
-- **A parent row in a correlated sub-select** — `exists (select 1 from
-- journals j where j.id = journal_sequences.journal_id and
-- has_capability(j.company_id, …))` — becomes
--
--     journal_id in (select j.id from journals j
--                     where j.company_id = any ((select companies_with_capability(…))::uuid[]))
--
-- The sub-select no longer refers to the row: Postgres runs it once, hashes
-- the ids it returns, and probes the hash for each row (a "hashed SubPlan"),
-- with `companies_with_capability()` an InitPlan inside it. The parent table
-- is read under its own policies in both forms, as the invoker, so a row of
-- the parent the caller may not see admits nothing before or after. It
-- applies to `journal_sequences`, `tax_filing_boxes` (read and write) and
-- `tax_filing_deposits`.
--
-- **The rest of the `has_capability()` policies** that an `or` or an `and`
-- kept out of the first rewrite — `api_keys`, `companies` (update),
-- `company_invitations`, `attachments_select_own_deposit` — get the same
-- form as the first rewrite, the other term carried over.
--
-- `with check` is left as it was everywhere: it is evaluated once per row
-- written, which is what a check is for, and `alter policy … using (…)`
-- does not touch it.
--
-- **Rights are unchanged.** `companies_with_capability(c)` contains a company
-- exactly when `has_capability(company, c)` is true —
-- `tests/capabilities.test.ts` compares the two over every preset and a
-- machine key — and `companies_of_caller()` exactly when
-- `is_company_member(company)` is true. `x = any (array)` is false, never
-- null, when the array is empty, and `in (…)` over a set of ids is true
-- exactly when the correlated `exists` was. `tests/socle_policies_ask_once.test.ts`
-- builds the database without this file, records the rows a member, a
-- member who holds no capability, a member of another company, a person of
-- no company, an instance administrator and two machine keys read, update
-- and delete in every table touched here, applies this file, and finds the
-- same; it also reads the plan of each table as a member.
--
-- ---------------------------------------------------------------------------
-- Left as they are, and why
--
-- `attachments_select` and `attachments_write` choose the capability with
-- `case when entity_type = 'tax_filing' or attachment_is_filing_deposit_file(id)`.
-- That function is a security definer that answers about one attachment —
-- deliberately, for callers who may not read the deposits (decision 0065) —
-- and it has no set-returning counterpart; writing it as a sub-select of the
-- policy would read the deposits as the invoker, which is a different right.
-- Both stay on the list of `tests/policies_ask_once.test.ts`; their two
-- branches already compare `company_id` against an InitPlan.

create or replace function companies_of_caller()
returns uuid[]
language sql
stable
security definer
set search_path = ekwo, pg_temp
as $$
  select coalesce(array_agg(x.company_id), '{}'::uuid[])
    from (
      select m.company_id
        from company_members m
       where m.user_id = auth.uid()
      union
      select k.company_id
        from api_keys k
       where k.key_hash = nullif(current_setting('ekwo.api_key', true), '')
    ) x
   where is_company_member(x.company_id);
$$;

comment on function companies_of_caller() is
  'The companies the current caller is on — the question is_company_member() answers, asked once for all of them: a member of it, or the holder of a machine key that still reaches something there. It is what a row level security policy compares company_id against, inside a sub-select, so that the answer is worked out once per statement instead of once per row. The counterpart of companies_with_capability().';

revoke execute on function companies_of_caller() from public, anon;
grant execute on function companies_of_caller() to authenticated, service_role;

-- is_company_member(), and `or is_instance_admin()` / `auth.uid()`.
alter policy companies_select on companies
  using (id = any ((select companies_of_caller())::uuid[]) or (select is_instance_admin()));

alter policy company_members_select on company_members
  using (user_id = auth.uid()
         or company_id = any ((select companies_of_caller())::uuid[])
         or (select is_instance_admin()));

alter policy company_filing_periods_select on company_filing_periods
  using (company_id = any ((select companies_of_caller())::uuid[]));

alter policy company_modules_select on company_modules
  using (company_id = any ((select companies_of_caller())::uuid[]));

alter policy company_tax_regimes_select on company_tax_regimes
  using (company_id = any ((select companies_of_caller())::uuid[]));

alter policy company_vat_schemes_select on company_vat_schemes
  using (company_id = any ((select companies_of_caller())::uuid[]));

alter policy matching_settings_select on matching_settings
  using (company_id = any ((select companies_of_caller())::uuid[]));

-- has_capability(), with another term.
alter policy companies_update on companies
  using (id = any ((select companies_with_capability('company.write'))::uuid[]) or (select is_instance_admin()));

alter policy api_keys_select on api_keys
  using (company_id = any ((select companies_with_capability('members.manage'))::uuid[]) or (select is_instance_admin()));

alter policy company_invitations_select on company_invitations
  using (company_id = any ((select companies_with_capability('members.manage'))::uuid[]) or (select is_instance_admin()));

alter policy attachments_select_own_deposit on attachments
  using (uploaded_by = auth.uid()
         and company_id = any ((select companies_with_capability('documents.deposit'))::uuid[]));

-- A parent row: the set of the parent's ids, worked out once.
alter policy journal_sequences_select on journal_sequences
  using (journal_id in (select j.id from journals j
                         where j.company_id = any ((select companies_with_capability('entries.read'))::uuid[])));

alter policy tax_filing_boxes_select on tax_filing_boxes
  using (filing_id in (select f.id from tax_filings f
                        where f.company_id = any ((select companies_with_capability('filings.read'))::uuid[])));

alter policy tax_filing_boxes_write on tax_filing_boxes
  using (filing_id in (select f.id from tax_filings f
                        where f.company_id = any ((select companies_with_capability('filings.write'))::uuid[])));

alter policy tax_filing_deposits_select on tax_filing_deposits
  using (filing_id in (select f.id from tax_filings f
                        where f.company_id = any ((select companies_with_capability('filings.read'))::uuid[])));

-- The revoke every file of this directory ends with.
revoke execute on all functions in schema ekwo from public;
