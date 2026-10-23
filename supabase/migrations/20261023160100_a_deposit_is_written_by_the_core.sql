-- Ekwo OS — a deposit is written by the core's functions, and by nobody else.
--
-- `tax_filing_deposits` is the proof a declaration went: when, by which
-- channel, under which reference, with which files, and what came back. Its
-- policy `tax_filing_deposits_write` let anybody holding `filings.write`
-- insert, rewrite or delete a row of it directly, past every rule the
-- functions apply: a send recorded on a declaration that was never prepared,
-- an outcome nobody answered, a deposit deleted after the administration
-- accepted it. Since `20261023124650` an application names files through
-- `record_filing_files()`, and the policy was left for one reader only, the
-- company archive — which loads deposits through `import_company()`, a
-- definer function that never needed it.
--
-- So the policy goes, and with it `insert`, `update` and `delete` on the
-- table, from `authenticated` and from `service_role` (which gets what a
-- person gets). What stays is `select`, under `tax_filing_deposits_select`.
-- The three functions that write a deposit write it as definer, each asking
-- what the policy asked — `filings.write`, or the installer — after the
-- company is one the caller may know of:
--
--   file_filing()            a send, as `20261007041207` wrote it
--   record_filing_outcome()  what came back, as `20260918110000` wrote it
--   record_filing_files()    the files of the send, already definer
--
-- `record_filing_outcome()` is also how the ledger records `paid`
-- (`tax_filings_paid_by_matching`), and there the person matching the payment
-- may keep the books without filing. Its body therefore moves, unchanged, into
-- `write_filing_outcome()`, which nobody may call: the function asks the
-- right and calls it, and the trigger calls it directly, as the ledger.

-- ---------------------------------------------------------------------------
-- 1. The table: read by whoever reads the declarations, written by the core
-- ---------------------------------------------------------------------------

drop policy if exists tax_filing_deposits_write on tax_filing_deposits;

revoke insert, update, delete on table tax_filing_deposits from authenticated, service_role;

comment on table tax_filing_deposits is
  'One send of a declaration and what came back. Written only by file_filing(), record_filing_outcome() and record_filing_files(); read under filings.read.';

-- ---------------------------------------------------------------------------
-- 2. write_filing_outcome — the body of record_filing_outcome, nobody's
-- ---------------------------------------------------------------------------

create or replace function write_filing_outcome(
  p_filing_id uuid,
  p_state     tax_filing_state,
  p_reference text default null,
  p_message   text default null
)
returns tax_filings
language plpgsql
volatile
security definer
set search_path = public, pg_temp
as $$
declare
  v_filing tax_filings;
begin
  select * into v_filing from tax_filings f where f.id = p_filing_id;
  if not found then
    raise exception 'not_found: filing %', p_filing_id using errcode = 'no_data_found';
  end if;

  if p_state not in ('accepted', 'rejected', 'paid') then
    raise exception 'not_an_outcome: % is not something an administration answers', p_state;
  end if;
  if v_filing.state = 'draft' or v_filing.state = 'ready' then
    raise exception 'filing_not_sent: a declaration that has not gone cannot come back %', p_state;
  end if;
  if p_state = 'paid' and v_filing.state <> 'accepted' then
    raise exception 'filing_not_accepted: paying follows acceptance, and this one is %', v_filing.state;
  end if;

  -- On the last send, because that is the one being answered.
  update tax_filing_deposits d
     set outcome    = p_state,
         outcome_at = now(),
         reference  = coalesce(p_reference, d.reference),
         message    = coalesce(p_message, d.message)
   where d.filing_id = p_filing_id
     and d.sequence = (select max(x.sequence) from tax_filing_deposits x where x.filing_id = p_filing_id);

  update tax_filings
     set state     = p_state,
         reference = coalesce(p_reference, reference)
   where id = p_filing_id
  returning * into v_filing;
  return v_filing;
end;
$$;

comment on function write_filing_outcome(uuid, tax_filing_state, text, text) is
  'Writes what came back on a declaration and on its last send, with no check of who asks: called by record_filing_outcome() once the caller''s right is checked, and by tax_filings_paid_by_matching as the ledger. Granted to nobody.';

revoke execute on function write_filing_outcome(uuid, tax_filing_state, text, text) from public, anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 3. record_filing_outcome — the right of the policy, asked by the function
-- ---------------------------------------------------------------------------

create or replace function record_filing_outcome(
  p_filing_id uuid,
  p_state     tax_filing_state,
  p_reference text default null,
  p_message   text default null
)
returns tax_filings
language plpgsql
volatile
security definer
set search_path = public, pg_temp
as $$
declare
  v_filing tax_filings;
begin
  select * into v_filing from tax_filings f where f.id = p_filing_id;
  if not found or not may_know_of_company(v_filing.company_id) then
    raise exception 'not_found: filing %', p_filing_id using errcode = 'no_data_found';
  end if;
  if not is_installer() and not has_capability(v_filing.company_id, 'filings.write') then
    raise exception 'not_allowed: recording what came back for a declaration in this company needs filings.write'
      using errcode = '42501';
  end if;
  return write_filing_outcome(p_filing_id, p_state, p_reference, p_message);
end;
$$;

comment on function record_filing_outcome(uuid, tax_filing_state, text, text) is
  'What came back: accepted, rejected, or paid, written on the declaration and on the send it answers — with the administration''s own words where it gave any. Paying follows acceptance, and a declaration that never went cannot come back at all. Asks filings.write.';

revoke execute on function record_filing_outcome(uuid, tax_filing_state, text, text) from public, anon;
grant execute on function record_filing_outcome(uuid, tax_filing_state, text, text) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 4. file_filing — `20261007041207` to the letter, as definer, asking the right
-- ---------------------------------------------------------------------------

create or replace function file_filing(
  p_filing_id uuid,
  p_reference text default null,
  p_filed_at  timestamptz default null,
  p_channel   filing_channel default 'portal',
  p_service   text default null
)
returns tax_filings
language plpgsql
volatile
security definer
set search_path = public, pg_temp
as $$
declare
  v_filing tax_filings;
  v_at     timestamptz;
  v_next   integer;
begin
  select * into v_filing from tax_filings f where f.id = p_filing_id;
  if not found or not may_know_of_company(v_filing.company_id) then
    raise exception 'not_found: filing %', p_filing_id using errcode = 'no_data_found';
  end if;
  if not is_installer() and not has_capability(v_filing.company_id, 'filings.write') then
    raise exception 'not_allowed: recording that a declaration of this company went needs filings.write'
      using errcode = '42501';
  end if;

  -- Rejected is a state a declaration is sent again from. It was never
  -- received, so there is nothing to correct and no corrective to open.
  if v_filing.state not in ('draft', 'ready', 'rejected') then
    raise exception 'filing_already_%: this declaration has already gone', v_filing.state;
  end if;

  if v_filing.prepared_at is null then
    raise exception 'filing_not_prepared: compute the figures before filing them';
  end if;

  v_at := coalesce(p_filed_at, now());

  select coalesce(max(d.sequence), 0) + 1 into v_next
    from tax_filing_deposits d where d.filing_id = p_filing_id;

  insert into tax_filing_deposits (filing_id, sequence, channel, service, sent_at, sent_by, reference)
  values (p_filing_id, v_next, p_channel, p_service, v_at, acting_user(), p_reference);

  update tax_filings
     set state     = 'filed',
         reference = coalesce(p_reference, reference),
         filed_at  = v_at,
         filed_by  = acting_user()
   where id = p_filing_id
  returning * into v_filing;

  return v_filing;
end;
$$;

comment on function file_filing(uuid, text, timestamptz, filing_channel, text) is
  'Records that a declaration has gone, with the reference the administration gave back, and keeps the send as a row of tax_filing_deposits. It asks that the figures were computed, not that there are any: a period where nothing happened is filed nil. A rejected declaration may be sent again — it was never received — and the second send is a second deposit, not a corrective. Asks filings.write.';

revoke execute on function file_filing(uuid, text, timestamptz, filing_channel, text) from public, anon;
grant execute on function file_filing(uuid, text, timestamptz, filing_channel, text) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 5. Paid by matching, through write_filing_outcome
--
-- `20261023124650` to the letter, but for the call: the person whose matching
-- pays the debt may keep the books without filing, and paid is the ledger's
-- fact, not that person's act.
-- ---------------------------------------------------------------------------

create or replace function tax_filings_paid_by_matching()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_filing  tax_filings;
  v_account uuid;
  v_open    numeric;
  v_was     numeric;
begin
  select * into v_filing from tax_filings f where f.settlement_entry_id = new.entry_id;
  if not found or v_filing.state not in ('accepted', 'paid') then
    return null;
  end if;

  -- Only the line that carries the net: the account the pack names for the
  -- side the period ended on. The tax accounts the entry cleared are not it.
  select account_id_by_code(v_filing.company_id,
           case when v_filing.credit_treatment is null then d.tax_payable_code
                else coalesce(d.tax_receivable_code, d.tax_payable_code) end)
    into v_account
    from companies c join country_defaults d on d.country = c.fiscal_country
   where c.id = v_filing.company_id;
  if v_account is distinct from new.account_id then
    return null;
  end if;

  v_open := abs(new.debit - new.credit) - new.matched_amount;
  v_was  := abs(old.debit - old.credit) - old.matched_amount;

  if v_filing.state = 'accepted' and v_open = 0 and v_was > 0 then
    perform write_filing_outcome(v_filing.id, 'paid');
  elsif v_filing.state = 'paid' and v_open > 0 and v_was = 0 then
    -- The payment was unmatched: the debt is open again, and so is the
    -- declaration's money. What the administration said stays said.
    perform write_filing_outcome(v_filing.id, 'accepted');
  end if;
  return null;
end;
$$;

comment on function tax_filings_paid_by_matching() is
  'Records a declaration paid once the line its settlement carried the net on is matched in full, and accepted again when that matching is undone — by whatever path the money was matched: the bank, auto_settle(), reconcile(), an import. Through write_filing_outcome(), the body of record_filing_outcome(), so the last send carries the outcome as it would by hand, whoever matched the payment.';

revoke execute on function tax_filings_paid_by_matching() from public, anon, authenticated, service_role;

revoke execute on all functions in schema public from public;
